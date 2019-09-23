package udprotean.shared.protocol;

import haxe.io.Bytes;


class SequentialCommunication
{
    /** The size of the sequential buffers in amount of datagrams. */
    public static inline var SequenceSize     = 512;
    /** The maximum transmittable datagram size in bytes. */
    public static inline var FragmentSize     = 540;
    /** The time after which an un-ACKed datagram should be re-sent. */
    public static inline var StaleDatagramAge = 200;
    public static inline var SequenceBytes    = 3;


    var sendingSequence: Sequence;      // Sending progress through sendingBuffer.
    var sendingAckSequence: Sequence;   // Sent dgrams that have been ACKed.
    var receivingSequence: Sequence;    // Receiving progress through receivingBuffer.
    var receivingAckSequence: Sequence; // Received dgrams that have been ACKed.
    var processingSequence: Sequence;   // Dgrams that have been processed.


    var sendingBuffer: DatagramBuffer;
    var receivingBuffer: DatagramBuffer;


    public function new()
    {
        // Initialize buffers.
        sendingBuffer = new DatagramBuffer(SequenceSize);
        receivingBuffer = new DatagramBuffer(SequenceSize);
    }


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
            fragment.blit(0, data, dataIndex, fragmentSize);
            
            dataIndex += fragmentSize;

            sendDatagram(fragment);
        }
    }


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
            sendAck(receivingSequence);
            receivingSequence.moveNext();
        }
        else if (!receivingBuffer.isEmpty(receivingSequence)
            && receivingBuffer.isStale(receivingSequence))
        {
            /*
             * We received a datagram with an unexpected sequence number.
             * Let the other end know which was the last datagram we received.
             */
            sendAck(receivingSequence.previous);
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
        transmit(datagramSequence);
    }

    /**
     * Goes through all the datagrams in the receiving buffer which have not yet been consumed.
     * This function makes sure that datagrams are consumed in order, and that fragmented
     * payloads are received to their entirety.
     * The `processingSequence` is used to track the last consumed datagram in the receiving buffer.
     */
    function processReceivingBuffer()
    {
        while (!receivingBuffer.isEmpty(processingSequence))
        {
            var fragmentCount: Int = getCompletedDatagramAt(processingSequence);
        }
    }


    /**
     * Checks if the potentially fragmented datagram, starting at the given position, is completed.
     * Meaning that all of its fragments are already stored in the buffer and in the correct order.
     *
     * @returns The number of fragments comprising the datagram.
     */
    function getCompletedDatagramAt(sequenceNum: Sequence): Int
    {
        var fragmentCount: Int = 1;
        var previousFragmentNum: Int = 0;

        while (!receivingBuffer.isEmpty(sequenceNum))
        {
            // Get the first byte, which is the fragment number.
            var fragmentNum: Int = receivingBuffer.get(sequenceNum).get(0);

            if (fragmentNum == 0)
            {
                return fragmentCount;
            }

            if (fragmentNum != previousFragmentNum - 1)
            {
                // INCOSISTENT FRAGMENT NUMBER
                // TODO: Raise some error.
            }

            fragmentCount++;
            previousFragmentNum = fragmentNum;
            sequenceNum.moveNext();
        }
        return 0;
    }


    function onReceivedAck(sequenceNumberAcked: Sequence)
    {
        // TODO
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
        // TODO: send the datagram over UDP
    }


    function transmit(bufferIndex: Int)
    {
        // TODO: send the datagram over UDP
        sendingBuffer.get(bufferIndex);
        sendingBuffer.refresh(bufferIndex);
    }
}
