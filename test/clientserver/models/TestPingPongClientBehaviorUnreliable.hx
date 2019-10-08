package clientserver.models;

import utest.Assert;
import seedyrng.Random;
import haxe.io.Bytes;
import udprotean.server.UDProteanClientBehavior;


class TestPingPongClientBehaviorUnreliable extends UDProteanClientBehavior
{
    override function initialize() 
    {
    }


    override function onMessage(message: Bytes)
    {
        sendUnreliable(message);
    }
}

