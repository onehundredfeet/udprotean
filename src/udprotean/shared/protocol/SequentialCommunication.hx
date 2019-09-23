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
    final SequenceBytes: Int;


    var sendingSequence: Sequence;      // Sending progress through sendingBuffer.
    var sendingAckSequence: Sequence;   // Sent dgrams that have been ACKed.
    var receivingSequence: Sequence;    // Receiving progress through receivingBuffer.
    var receivingAckSequence: Sequence; // Received dgrams that have been ACKed.
    var processingSequence: Sequence;   // Dgrams that have been processed.


    var sendingBuffer: DatagramBuffer;
    var receivingBuffer: DatagramBuffer;


    public function new()
    {
        // Calculate the amount of bytes needed to represent the sequence.
        var sequenceBytes = 0;
        while (Math.pow(2, sequenceBytes * 8) < SequenceSize)
            sequenceBytes++;
        SequenceBytes = sequenceBytes;

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


    function sendDatagram(fragment: Bytes)
    {
        // Get the sequence number for this datagram according to sendingSequence.
        var datagramSequenceNumber: Sequence = sendingSequence.getAndMoveNext();

        // Allocate the size of the datagram.
        var datagram: Bytes = Bytes.alloc(SequenceBytes + fragment.length);

        // Write sequence number goes into the first bytes.
        datagram.setInt32(0, datagramSequenceNumber);

        // Write the fragment into the rest.
        datagram.blit(SequenceBytes, fragment, 0, fragment.length);

        // Store the datagram in the sending buffer.
        sendingBuffer.insert(datagramSequenceNumber, datagram);

        /*
        * Empty the next spot in the circular buffer.
        * This is done to ensure separation between this
        * and the previous cycle of values.
        * Helps clearing the buffer backwards upon
        * acknowledgements without deleting newer payloads.
        */
        sendingBuffer.clear(datagramSequenceNumber.next);

        // Finally, transmit the datagram.
        transmit(datagramSequenceNumber);
    }


    function transmit(bufferIndex: Int)
    {
        // TODO: send the datagram over UDP
        sendingBuffer.get(bufferIndex);
        sendingBuffer.refresh(bufferIndex);
    }
}
