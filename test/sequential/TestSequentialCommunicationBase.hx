package sequential;

import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


@:access(udprotean.shared.protocol.SequentialCommunication)
class TestSequentialCommunicationBase extends SequentialCommunication implements ITest
{
    final SequenceSize = SequentialCommunication.SequenceSize;
    final SequenceBytes = SequentialCommunication.SequenceBytes;
    final FragmentSize = SequentialCommunication.FragmentSize;

    var sendExpected: Int = 0;


    public function new()
    {
        super();
    }


    function test_getCompletedDatagramAt()
    {
        // Test not completed
        receivingBuffer.insert(12, b("0112"));
        receivingBuffer.insert(14, b("0034"));
        Assert.equals(0, getCompletedDatagramAt(12));
        
        // Test completed
        receivingBuffer.insert(20, b("0278"));
        receivingBuffer.insert(21, b("0199"));
        receivingBuffer.insert(22, b("00FA"));
        Assert.equals(3, getCompletedDatagramAt(20));

        // Test cycling completed
        receivingBuffer.insert(SequenceSize - 2, b("0368"));
        receivingBuffer.insert(SequenceSize - 1, b("026967"));
        receivingBuffer.insert(0, b("0199"));
        receivingBuffer.insert(1, b("0032"));
        Assert.equals(5, getCompletedDatagramAt(SequenceSize - 2));
    }


    function teardown()
    {
        sendingBuffer = new DatagramBuffer(SequenceSize);
        receivingBuffer = new DatagramBuffer(SequenceSize);
        sendExpected = 0;
    }


    static inline function b(hex: String): Bytes
    {
        return Bytes.ofHex(hex);
    }


    function dgramInt(seq: Int, frag: Int, data: Int)
    {
        var buffer: Bytes = Bytes.alloc(Std.int(SequenceBytes + 1 + 4));
        buffer.setInt32(0, seq);
        buffer.set(SequenceBytes, frag);
        buffer.setInt32(SequenceBytes + 1, data);
        return buffer;
    }
}
