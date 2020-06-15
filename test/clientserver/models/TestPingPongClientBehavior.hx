package clientserver.models;

import utest.Assert;
import seedyrng.Seedy;
import haxe.io.Bytes;
import udprotean.shared.UdpSocketLayer;
import udprotean.server.UDProteanClientBehavior;


class TestPingPongClientBehavior extends UDProteanClientBehavior
{
    public var expected: Int;


    override function initialize()
    {
        expected = 0;
    }


    override function onMessage(message: Bytes)
    {
        var num: Int = message.getInt32(0);

        Assert.equals(expected, num);

        expected++;

        send(message);

        if (Seedy.random() < 0.01)
        {
            sendMaliciousMessage();
        }
    }


    /**
     * Tests the client's ability to drop messages received from someone
     * other than the server.
     */
    function sendMaliciousMessage()
    {
        var randomBuffer: Bytes = Bytes.alloc(4);
        randomBuffer.setInt32(0, Seedy.randomInt(0, 65535));

        var newSocket: UdpSocketLayer = new UdpSocketLayer();
        newSocket.send(randomBuffer, peerAddress);
    }
}

