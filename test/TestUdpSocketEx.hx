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
        client.connect("127.0.0.1", 9000);
    }


    function testBasicSendReceive()
    {
        client.send(Bytes.ofString("ping"));

        var serverRecv = server.receive().toString();
        Assert.equals("ping", serverRecv);

        server.sendTo(Bytes.ofString("pong"), server.recvFromAddress());

        var clientRecv = client.receive().toString();
        Assert.equals("pong", clientRecv);
    }


    @Ignored
    function testReadTimeout()
    {
        trace(1);
        var serverRecv: Bytes = server.readTimeout(0.5);
        Assert.equals(null, serverRecv);
        trace(2);
        
        client.send(Bytes.ofString("ping"));

        var serverRecvMsg = server.readTimeout(0.5).toString();
        Assert.equals("ping", serverRecvMsg);
    }
}
