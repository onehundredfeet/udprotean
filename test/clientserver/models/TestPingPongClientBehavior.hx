package clientserver.models;

import utest.Assert;
import seedyrng.Random;
import haxe.io.Bytes;
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

        send(message, false);
    }
}

