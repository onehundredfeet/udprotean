package clientserver.models;

import haxe.io.Bytes;
import utest.Assert;
import udprotean.client.UDProteanClient;
import udprotean.shared.UDProteanPeer;


class TestPingPongClient extends UDProteanClient
{
    public var count: Int;
    public var expected: Int;


    override function initialize() 
    {
        expected = 0;
    }


    override function onConnect() 
    {
    }


    override function onMessage(message: Bytes) 
    {
        var num: Int = message.getInt32(0);
        
        Assert.equals(expected, num);

        expected++;

        if (expected < count)
            sendInt(expected);
    }

    
    public function sendInt(int: Int)
    {
        var b = Bytes.alloc(4);
        b.setInt32(0, int);
        send(b);
    }
}
