package shared;

import udprotean.shared.Utils;
import seedyrng.Seedy;
import utest.Async;
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

    var serverAddress: Address;


    public function setup()
    {
        var port = Seedy.randomInt(1025, 65535);

        server = new  UdpSocketEx();
        server.listen("127.0.0.1", port);

        client = new UdpSocketEx();
        client.connect(new Host("127.0.0.1"), port);

        serverAddress = new Address();
        serverAddress.host = Utils.ipToNum("127.0.0.1");
        serverAddress.port = port;
    }


    function teardown()
    {
        if (server.isConnected())
            server.close();

        if (client.isConnected())
            client.close();
    }


    function testReadFail()
    {
        var nullResp = client.read();
        Assert.equals(null, nullResp);
    }


    @:timeout(2000)
    function testBasicSendReceive(async: Async)
    {
        client.send(Bytes.ofString("ping"));

        var serverRecv = server.read().toString();
        Assert.equals("ping", serverRecv);

        server.sendTo(Bytes.ofString("pong"), server.recvFromAddress());

        var clientRecv = client.read().toString();
        Assert.equals("pong", clientRecv);

        client.close();

        var nullResp = server.trySendAndRead(Bytes.ofString("fail"), server.recvFromAddress());
        Assert.equals(null, nullResp);

        async.done();
    }


    @:timeout(2000)
    function testReadTimeout(async: Async)
    {
        var serverRecv: Bytes = server.readTimeout(0.5);
        Assert.equals(null, serverRecv);

        client.send(Bytes.ofString("ping"));

        var serverRecvMsg = server.readTimeout(0.5).toString();
        Assert.equals("ping", serverRecvMsg);

        async.done();
    }
}
