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
class TestSequentialCommunicationReceiveFragment extends TestSequentialCommunicationBase implements ITest
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


    override function onTransmit(datagram: Bytes) 
    {
        Assert.equals(SequenceBytes, datagram.length);

        var sequenceNumber = Sequence.fromBytes(datagram);
        Assert.equals(expectedAck, sequenceNumber);

        expectedAck.moveNext();
    }


    override function onMessageReceived(datagram: Bytes) 
    {
        var payload = datagram.getInt32(0);

        Assert.equals(sendExpected * 2, payload);
        sendExpected++;
    }
}
