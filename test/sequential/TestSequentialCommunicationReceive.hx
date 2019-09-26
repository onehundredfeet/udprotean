package sequential;

import seedyrng.Random;
import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


@:access(udprotean.shared.protocol.SequentialCommunication)
class TestSequentialCommunicationReceive extends TestSequentialCommunicationBase implements ITest
{
    var expectedAck: Sequence;
    var rand: Random;


    function setup()
    {
        expectedAck = 0;
        rand = new Random();
    }


    function testReceive()
    {
        var buffers = new Array<Bytes>();
        var count = SequenceSize;

        for (i in 0...count)
        {
            var buffer = dgramInt(i % SequenceSize, 0, i * 2);

            buffers.push(buffer);
        }

        for (buffer in buffers)
        {
            onReceived(buffer);
        }

        Assert.equals(count, sendExpected);
        Assert.equals(count % SequenceSize, expectedAck);
    }


    override function onTransmit(message: Bytes) 
    {
        Assert.equals(SequenceBytes, message.length);

        var sequenceNumber = Sequence.fromBytes(message);
        Assert.equals(expectedAck, sequenceNumber);

        expectedAck.moveNext();
    }


    override function onMessageReceived(message: Bytes) 
    {
        var payload = message.getInt32(0);

        Assert.equals(sendExpected * 2, payload);
        sendExpected++;
    }
}
