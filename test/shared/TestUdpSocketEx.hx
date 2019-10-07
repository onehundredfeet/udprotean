package shared;

import haxe.macro.Expr.Catch;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import sys.net.Address;
import sys.net.Host;

import udprotean.shared.UdpSocketEx;

class TestUdpSocketEx extends Test
{
    var server: UdpSocketEx;
    var client: UdpSocketEx;


    public function setup()
    {
        server = new  UdpSocketEx();
        server.listen("127.0.0.1", 9000);

        client = new UdpSocketEx();
        client.connect(new Host("127.0.0.1"), 9000);
    }


    function teardown()
    {
        server.close();
        client.close();
    }


    function testBasicSendReceive()
    {
        client.send(Bytes.ofString("ping"));

        var serverRecv = server.read().toString();
        Assert.equals("ping", serverRecv);

        server.sendTo(Bytes.ofString("pong"), server.recvFromAddress());

        var clientRecv = client.read().toString();
        Assert.equals("pong", clientRecv);
    }


    function testReadTimeout()
    {
        var serverRecv: Bytes = server.readTimeout(0.5);
        Assert.equals(null, serverRecv);
        
        client.send(Bytes.ofString("ping"));

        var serverRecvMsg = server.readTimeout(0.5).toString();
        Assert.equals("ping", serverRecvMsg);
    }
}
