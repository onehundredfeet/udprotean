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
class TestSequentialCommunicationReceive extends TestSequentialCommunicationBase implements ITest
{
    var expectedAck: Sequence;


    function setup()
    {
        expectedAck = 0;
    }


    function testReceive()
    {
        var count = SequenceSize * 3;

        for (i in 0...count)
        {
            var buffer = dgramInt(i % SequenceSize, 0, i * 2);

            onReceived(buffer);
        }
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
        var sequenceNumber = Sequence.fromBytes(datagram);
        var data = datagram.sub(SequenceBytes, datagram.length - SequenceBytes);
        var fragmentNum = data.get(0);
        var payload = data.getInt32(1);

        Assert.equals(0, fragmentNum);
        Assert.equals(sendExpected % SequenceSize, sequenceNumber);
        Assert.equals(sendExpected * 2, payload);
        sendExpected++;
    }
}
