import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


@:access(udprotean.shared.protocol.SequentialCommunication)
class TestSequentialCommunication extends Test
{
    final SequenceSize = SequentialCommunication.SequenceSize;


    function test_getCompletedDatagramAt()
    {
        var seqComm: SequentialCommunication = new SequentialCommunication();

        // Test not completed
        seqComm.receivingBuffer.insert(12, Bytes.ofHex("0112"));
        seqComm.receivingBuffer.insert(14, Bytes.ofHex("0034"));
        Assert.equals(0, seqComm.getCompletedDatagramAt(12));
        
        // Test completed
        seqComm.receivingBuffer.insert(20, Bytes.ofHex("0278"));
        seqComm.receivingBuffer.insert(21, Bytes.ofHex("0199"));
        seqComm.receivingBuffer.insert(22, Bytes.ofHex("00FA"));
        Assert.equals(3, seqComm.getCompletedDatagramAt(20));

        // Test cycling completed
        seqComm.receivingBuffer.insert(SequenceSize - 2, Bytes.ofHex("0368"));
        seqComm.receivingBuffer.insert(SequenceSize - 1, Bytes.ofHex("026967"));
        seqComm.receivingBuffer.insert(0, Bytes.ofHex("0199"));
        seqComm.receivingBuffer.insert(1, Bytes.ofHex("0032"));
        Assert.equals(5, seqComm.getCompletedDatagramAt(SequenceSize - 2));
    }
}
