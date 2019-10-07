package clientserver.models;

import haxe.io.Bytes;
import utest.Assert;
import udprotean.client.UDProteanClient;
import udprotean.shared.UDProteanPeer;


class TestPingPongClientUnreliable extends UDProteanClient
{
    public var received: Int;


    override function initialize() 
    {
        received = 0;
    }


    override function onConnect() 
    {
    }


    override function onMessage(message: Bytes) 
    {
        received = message.getInt32(0);
    }

    
    public function sendInt(int: Int)
    {
        var b = Bytes.alloc(4);
        b.setInt32(0, int);
        sendUnreliable(b);
    }
}
