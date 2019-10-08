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


class TestSequentialCommunicationReceive extends TestSequentialCommunicationBase implements ITest
{
    var expectedAck: Sequence;
    var rand: Random;


    override function setup()
    {
        super.setup();

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

    function testReceiveDuplicates()
    {
        var buffer0 = dgramInt(0, 3, 0);
        var buffer1 = dgramInt(1, 2, 0);
        var buffer2 = dgramInt(2, 1, 0);
        var buffer3 = dgramInt(3, 0, 0);

        onReceived(buffer0);
        onReceived(buffer0);
        onReceived(buffer0);
        onReceived(buffer1);
        onReceived(buffer2);
        onReceived(buffer1);
        onReceived(buffer2);
        onReceived(buffer3);
        onReceived(buffer3);

        Assert.equals(1, sendExpected);
        Assert.equals(4, expectedAck);
    }


    function testReceiveFragmented()
    {
        var frag0 = dgramInt(0, 2, 0);
        var frag1 = dgramInt(1, 1, 0);
        var frag2 = dgramInt(2, 0, 0);

        onReceived(frag0);
        onReceived(frag1);
        onReceived(frag2);

        Assert.equals(1, sendExpected);
        Assert.equals(3, expectedAck);
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
