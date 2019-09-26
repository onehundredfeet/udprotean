package sequential;

import seedyrng.Seedy;
import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;

import sequential.models.SequentialCommunicationPeer;


class TestSequentialCommunication implements ITest
{
    var peer1: SequentialCommunicationPeer;
    var peer2: SequentialCommunicationPeer;

    var peer1expect: Int;
    var peer2expect: Int;


    public function new()
    {

    }


    function setup()
    {
        peer1 = new SequentialCommunicationPeer(peer1receive);
        peer2 = new SequentialCommunicationPeer(peer2receive);
        peer1expect = 0;
        peer2expect = 0;

        peer1.setOther(peer2);
        peer2.setOther(peer1);
    }


    function testSend()
    {
        sendIncreasingSequence(SequentialCommunication.SequenceSize * 4);
    }


    function testSendPacketLoss()
    {
        sendIncreasingSequence(SequentialCommunication.SequenceSize, 0.1, 2000);
    }

    @Ignored
    function testSendBigPacketLoss()
    {
        Assert.isTrue(true);
        sendIncreasingSequence(SequentialCommunication.SequenceSize, 0.5, 50000);
    }


    function sendIncreasingSequence(count: Int, packetLoss: Float = 0, updateAttempts: Int = 0)
    {
        peer1.setPacketLoss(packetLoss);
        peer2.setPacketLoss(packetLoss);

        var peer1send = new Array<Bytes>();
        var peer2send = new Array<Bytes>();

        for (i in 0...count)
        {
            var b = Bytes.alloc(4);
            b.setInt32(0, i * 2);

            peer1send.push(b);
            peer2send.push(b);
        }

        for (i in 0...peer1send.length)
        {
            peer1.send(peer1send[i]);
        }
        for (i in 0...peer2send.length)
        {
            peer2.send(peer2send[i]);
        }

        for (i in 0...updateAttempts)
        {
            peer1.update();
            peer2.update();
        }

        Assert.equals(peer1send.length, peer1expect);
        Assert.equals(peer2send.length, peer2expect);
    }


    function peer1receive(message: Bytes)
    {
        var num = message.getInt32(0);
        Assert.equals(peer1expect * 2, num);
        peer1expect++;
    }


    function peer2receive(message: Bytes)
    {
        var num = message.getInt32(0);
        Assert.equals(peer2expect * 2, num);
        peer2expect++;
    }
}
