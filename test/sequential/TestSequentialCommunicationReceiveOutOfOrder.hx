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
class TestSequentialCommunicationReceiveOutOfOrder extends TestSequentialCommunicationBase implements ITest
{
    var rand: Random;


    function setup()
    {
        rand = new Random();
    }


    function testReceive()
    {
        var buffers = new Array<Bytes>();
        var count = SequenceSize - 16;

        for (i in 0...count)
        {
            var buffer = dgramInt(i % SequenceSize, 0, i * 2);

            buffers.push(buffer);
        }

        rand.shuffle(buffers);

        for (buffer in buffers)
        {
            onReceived(buffer);
        }

        Assert.equals(count, sendExpected);
    }


    override function onTransmit(message: Bytes) 
    {
        // Unexpected order of ACKs
    }


    override function onMessageReceived(message: Bytes) 
    {
        var payload = message.getInt32(0);

        Assert.equals(sendExpected * 2, payload);
        sendExpected++;
    }
}
