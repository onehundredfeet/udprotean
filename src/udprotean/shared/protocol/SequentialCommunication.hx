package udprotean.shared.protocol;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;


class SequentialCommunication
{
    /** The size of the sequential buffers in amount of datagrams. */
    public static inline var SequenceSize     = 512;
    /** The maximum transmittable datagram size in bytes. */
    public static inline var FragmentSize     = 540;
    /** The time (in ms) after which an un-ACKed datagram should be re-sent. */
    public static inline var StaleDatagramAge = 20;
    /** The number of bytes needed to hold the sequence number in datagrams. */
    public static inline var SequenceBytes    = 3;


    var sendingSequence: Sequence = 0;      // Sending progress through sendingBuffer.
    var sendingAckSequence: Sequence = 0;   // Sent dgrams that have been ACKed.
    var receivingSequence: Sequence = 0;    // Receiving progress through receivingBuffer.
    var receivingAckSequence: Sequence = 0; // Received dgrams that have been ACKed.
    var processingSequence: Sequence = 0;   // Dgrams that have been processed.


    var sendingBuffer: DatagramBuffer;
    var receivingBuffer: DatagramBuffer;


    public function new()
    {
        // Initialize buffers.
        sendingBuffer = new DatagramBuffer(SequenceSize);
        receivingBuffer = new DatagramBuffer(SequenceSize);
    }


    /**
     * Send a payload datagram.
     * Due to fragmentation, the maximum size for a single datagram is (255 * FragmentSize).
     */
    public function send(data: Bytes)
    {
        var fragmentCount: Int = Std.int(data.length / FragmentSize) + 1;
        var dataIndex: Int = 0;

        while (fragmentCount > 0)
        {
            fragmentCount--;

            var fragmentSize: Int = Std.int(Math.min(data.length - dataIndex, FragmentSize));

            var fragment: Bytes = Bytes.alloc(fragmentSize + 1);

            fragment.set(0, fragmentCount);
            fragment.blit(1, data, dataIndex, fragmentSize);
            
            dataIndex += fragmentSize;

            sendDatagram(fragment);
        }
    }


    /**
     * Process a received datagram, as it was received on the socket.
     */
    public function onReceived(datagram: Bytes)
    {
        var datagramSequence: Sequence = Sequence.fromBytes(datagram);

        // If the datagram is only SequenceBytes long, then it's an ACK.
        if (datagram.length == SequenceBytes)
        {
            onReceivedAck(datagramSequence);
            return;
        }

        // Check if we already have this datagram and we just haven't ACKed it yet.
        if (datagramSequence.isBetween(receivingAckSequence, receivingSequence))
        {
            // TODO: Should it be inclusively between?
            return;
        }

        // Keep the payload in the datagramm by removing the sequence bytes,
        // and add it to the receiving buffer at its position in the sequence.
        var data: Bytes = datagram.sub(SequenceBytes, datagram.length - SequenceBytes);
        receivingBuffer.insert(datagramSequence, data);

        if (datagramSequence == receivingSequence)
        {
            /*
             * This datagram is on-par with the sequence.
             */
            processReceivingBuffer();

            sendAck(receivingSequence);
            receivingSequence.moveNext();

        }
        else if (receivingBuffer.isStale(receivingSequence))
        {
            /*
             * We received a datagram with an unexpected sequence number.
             * Let the other end know which was the last datagram we received.
             */
            sendAck(receivingSequence.previous);
        }
    }


    /**
     * Update method meant to be called periodically.
     * This method re-sends messages that have not been acknowledged,
     * and requests repeats of expected messages that have not been received.
     */
    public function update()
    {
        // Repeat everything from the last ACKed message up to the end of the sending buffer.
        var sendingFlushSequence: Sequence = sendingAckSequence;
        while (sendingFlushSequence != sendingSequence)
        {
            if (sendingBuffer.isStale(sendingFlushSequence))
            {
                transmitFromBuffer(sendingFlushSequence);
            }
            sendingFlushSequence.moveNext();
        }
    }


    function sendDatagram(fragment: Bytes)
    {
        // Get the sequence number for this datagram according to sendingSequence.
        var datagramSequence: Sequence = sendingSequence.getAndMoveNext();

        // Allocate the size of the datagram.
        var datagram: Bytes = Bytes.alloc(SequenceBytes + fragment.length);

        // Write sequence number goes into the first bytes.
        datagram.setInt32(0, datagramSequence);

        // Write the fragment into the rest.
        datagram.blit(SequenceBytes, fragment, 0, fragment.length);

        // Store the datagram in the sending buffer.
        sendingBuffer.insert(datagramSequence, datagram);

        /*
        * Empty the next spot in the circular buffer.
        * This is done to ensure separation between this
        * and the previous cycle of values.
        * Helps clearing the buffer backwards upon
        * acknowledgements without deleting newer datagrams.
        */
        sendingBuffer.clear(datagramSequence.next);

        // Finally, transmit the datagram.
        transmitFromBuffer(datagramSequence);
    }

    /**
     * Goes through all the datagrams in the receiving buffer which have not yet been consumed.
     * This function makes sure that datagrams are consumed in order, and that fragmented
     * payloads are received to their entirety.
     * The `processingSequence` is used to track the last consumed datagram in the receiving buffer.
     *
     * @returns The amount of positions the processing sequence was moved by.
     */
    function processReceivingBuffer(): Int
    {
        var stepCount: Int = 0;

        while (!receivingBuffer.isEmpty(processingSequence))
        {
            var datagramLength: Int = getCompletedDatagramAt(processingSequence);

            if (datagramLength > 0)
            {
                // There is a completed datagram at the current position.
                var datagram: Bytes = Bytes.alloc(datagramLength);
                var bufferIndex: Int = 0;

                while (bufferIndex < datagramLength)
                {
                    var fragment: Bytes = receivingBuffer.get(processingSequence);

                    // Write the fragment to the datagram, excluding the first byte
                    // which is the fragment number.
                    datagram.blit(bufferIndex, fragment, 1, fragment.length - 1);

                    // Clear the datagram we just read.
                    receivingBuffer.clear(processingSequence);

                    bufferIndex += fragment.length - 1;
                    stepCount++;

                    if (processingSequence == receivingSequence.next)
                    {
                        /*
                         * If we are progressing past the receiving sequence, then it means
                         * that the datagram that was just received filled a gap in the receiving sequence,
                         * and allowed the processing sequence to go past the receiving one.
                         * In this case we should also pull up the receiving sequence so that
                         * it doesn't stay behind what is being processed for two reasons:
                         * - ACKs should not be sent for datagrams that are not the last one that we actually have.
                         * - The processReceivingBuffer() method will not be called properly if processing > receiving.
                         */
                        receivingSequence.moveNext();
                    }
                    processingSequence.moveNext();
                }

                handleDatagram(datagram);
            }
            else
            {
                break;
            }
        }

        return stepCount;
    }


    /**
     * Checks if the potentially fragmented datagram, starting at the given position, is completed.
     * Meaning that all of its fragments are already stored in the buffer and in the correct order.
     *
     * @returns The length in bytes of the datagram, or `0` if there is no completed datagram.
     */
    function getCompletedDatagramAt(sequenceNum: Sequence): Int
    {
        var datagramLength: Int = 0;
        var previousFragmentNum: Int = 0;

        while (!receivingBuffer.isEmpty(sequenceNum))
        {
            var fragment: Bytes = receivingBuffer.get(sequenceNum);

            // Get the first byte, which is the fragment number.
            var fragmentNum: Int = fragment.get(0);
            var fragmentPayloadLength: Int = fragment.length - 1;

            datagramLength += fragmentPayloadLength;

            if (fragmentNum == 0)
            {
                return datagramLength;
            }

            if (previousFragmentNum > 0
                && fragmentNum != previousFragmentNum - 1)
            {
                // INCONSISTENT FRAGMENT NUMBER
                // TODO: Raise some error.
                trace("INCONSISTENT");
                return 0;
            }

            previousFragmentNum = fragmentNum;
            sequenceNum.moveNext();
        }

        return 0;
    }


    function onReceivedAck(sequenceNumberAcked: Sequence)
    {
        if (sequenceNumberAcked == sendingAckSequence)
        {
            /*
             * Received an expected ACK on-sequence.
             * Cleared the ACKed datagram from the sending buffer,
             * as well as any datagrams before it.
             */
            var bufferClearSequence: Sequence = sendingAckSequence.getAndMoveNext();

            while (!sendingBuffer.isEmpty(bufferClearSequence)
                && bufferClearSequence != sendingAckSequence)
            {
                sendingBuffer.clear(bufferClearSequence);
                bufferClearSequence.movePrevious();
            }
        }
        else
        {
            /*
            * We received an ACK for a datagram that was not the last on the sequence.
            * Resend the datagram that is after the one being acknowledged.
            */
            sendingAckSequence.set(sequenceNumberAcked.next);

            if (!sendingBuffer.isEmpty(sendingAckSequence))
            {
                transmitFromBuffer(sendingAckSequence);
            }
        }
    }


    function sendAck(sequenceNumber: Sequence)
    {
        // Upda the receiving ack sequence to point to the last number ACKed.
        receivingAckSequence.set(sequenceNumber);

        // Refresh the timestamp on the datagram being ACKed.
        sendingBuffer.refresh(sequenceNumber);

        // Send the ACK.
        var ackDatagram: Bytes = Bytes.alloc(SequenceBytes);
        ackDatagram.setInt32(0, sequenceNumber);
        onTransmit(ackDatagram);
    }


    function transmitFromBuffer(bufferIndex: Int)
    {
        var datagram: Bytes = sendingBuffer.get(bufferIndex);
        sendingBuffer.refresh(bufferIndex);
        onTransmit(datagram);
    }


    function handleDatagram(datagram: Bytes)
    {
        onMessageReceived(datagram);
    }


    function onTransmit(datagram: Bytes)        { throw "Not implemented, function should be overriden."; }
    function onMessageReceived(datagram: Bytes) { throw "Not implemented, function should be overriden."; }
}
