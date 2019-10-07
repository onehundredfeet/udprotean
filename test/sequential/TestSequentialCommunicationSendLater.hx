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
class TestSequentialCommunicationSendLater extends TestSequentialCommunicationBase implements ITest
{
    function testSendLater()
    {
        var msg1 = Bytes.alloc(4);
        msg1.setInt32(0, 5);
        var msg2 = Bytes.alloc(4);
        msg2.setInt32(0, 6);

        send(msg1, false);
        send(msg2, false);

        Assert.equals(2, sendingSequence);
        Assert.equals(0, sendingAckSequence);

        Assert.equals(0, sendExpected);

        sendExpected = 5;

        update();

        Assert.equals(7, sendExpected);
    }

    override function onTransmit(message: Bytes) 
    {
        var sequenceNumber = Sequence.fromBytes(message);
        var data = message.sub(SequenceBytes, message.length - SequenceBytes);
        var fragmentNum = data.get(0);
        var payload = data.getInt32(1);

        Assert.equals(sendExpected - 5, sequenceNumber);
        Assert.equals(0, fragmentNum);
        Assert.equals(sendExpected, payload);
        sendExpected++;
    }
}
