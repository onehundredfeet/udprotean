package shared;

import udprotean.shared.UdpSocketLayer;
import udprotean.client.ClientUdpSocket;
import udprotean.server.ServerUdpSocket;
import udprotean.shared.Utils;
import utest.Async;
import utest.Assert;
import utest.Test;
import sys.net.Address;
import sys.net.Host;
import haxe.io.Bytes;
import seedyrng.Seedy;


@:access(udprotean.shared.UdpSocketLayer)
class TestUdpSocketLayer extends Test
{
    var server: UdpSocketLayer;
    var client: UdpSocketLayer;

    var serverAddress: Address;


    public function setup()
    {
        var port = Seedy.randomInt(1025, 65535);

        server = new  UdpSocketLayer();
        server.listen("127.0.0.1", port);

        client = new UdpSocketLayer();
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
        var nullResp = client.readFromPeer();
        Assert.equals(null, nullResp);
    }


    @:timeout(2000)
    function testBasicSendReceive(async: Async)
    {
        client.sendToPeer(Bytes.ofString("ping"));

        var serverRecv = server.read().toString();
        Assert.equals("ping", serverRecv);

        server.send(Bytes.ofString("pong"), server.recvFromAddress());

        var clientRecv = client.readFromPeer().toString();
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
        clearErrors();

        client.sendToPeer(Bytes.ofString("ping"));
        checkErrors();

        var serverRecvMsg = server.readTimeout(0.5).toString();
        Assert.equals("ping", serverRecvMsg);
        checkErrors();

        async.done();
    }


    function checkErrors()
    {
        if (server.error != null)
        {
            throw server.error;
        }

        if (client.error != null)
        {
            throw client.error;
        }

        clearErrors();
    }


    function clearErrors()
    {
        server.error = null;
        client.error = null;
    }
}
