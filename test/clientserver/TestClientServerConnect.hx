package clientserver;

import udprotean.shared.UDProteanPeer;
import sys.thread.Thread;
import haxe.Timer;
import utest.Async;
import clientserver.models.TestConnectClient;
import clientserver.models.TestConnectClientBehavior;
import udprotean.client.UDProteanClient;
import udprotean.server.UDProteanServer;
import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;


@:access(udprotean.server.UDProteanServer)
class TestClientServerConnect implements ITest
{
    final ServerUpdates = 100;

    var server: UDProteanServer;
    var client: TestConnectClient;
    var clients: Array<UDProteanClient>;


    public function new() { }


    function setup()
    {
        UDProteanPeer.PacketLoss = 0;
        server = new UDProteanServer("127.0.0.1", 9000, TestConnectClientBehavior);
        client = new TestConnectClient("127.0.0.1", 9000);
        clients = new Array<UDProteanClient>();
    }


    function teardown()
    {
        UDProteanPeer.PacketLoss = 0;
        client.disconnect(0.00001);
        for (c in clients) c.disconnect(0.00001);
        server.stop();
    }


    function testNotConnect()
    {
        var connected: Bool = client.connectTimeout(0.3);

        Assert.isTrue(client.initializeCalled);
        Assert.isFalse(client.onConnectCaled);
        Assert.isFalse(connected);
    }


    @:timeout(1000)
    function testConnect(async: Async)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        runServer(serverBranch, 1);        
        
        var connected: Bool = client.connectTimeout(0.5);

        Assert.isTrue(client.initializeCalled);
        Assert.isTrue(client.onConnectCaled);
        Assert.isTrue(connected);

        clientBranch.done();
    }


    @:timeout(3000)
    function testConnectMultiple(async: Async)
    {
        UDProteanPeer.PacketLoss = 0.1;

        var numOfClients = 16;
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        runServer(serverBranch, numOfClients);

        for (_ in 0...numOfClients)
        {
            var client = new TestConnectClient("127.0.0.1", 9000);
            clients.push(client);

            var connected = client.connectTimeout(0.5);

            Assert.isTrue(client.initializeCalled);
            Assert.isTrue(client.onConnectCaled);
            Assert.isFalse(client.onDisconnectCalled);
            Assert.isTrue(connected);
        }

        clientBranch.done();
    }


    @:timeout(3000)
    function testDisconnect(async: Async)
    {
        var numOfClients = 16;
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        runServer(serverBranch, 0);

        for (_ in 0...numOfClients)
        {
            var client = new TestConnectClient("127.0.0.1", 9000);
            clients.push(client);
            
            var connected = client.connectTimeout(0.5);

            Assert.isTrue(client.initializeCalled);
            Assert.isTrue(client.onConnectCaled);
            Assert.isFalse(client.onDisconnectCalled);
            Assert.isTrue(connected);

            client.disconnect(0.5);

            Assert.isTrue(client.onDisconnectCalled);
        }

        clientBranch.done();
    }


    function runServer(async: Async, expectedPeerCount: Int): Thread
    {
        return Thread.create(() -> {
            
            server.start();

            for (_ in 0...ServerUpdates)
            {
                server.update();
            }

            Assert.equals(expectedPeerCount, Lambda.count(server.peers));

            for (peer in server.peers)
            {
                var peerCasted: TestConnectClientBehavior = cast peer;
                Assert.isTrue(peerCasted.initializeCalled);
                Assert.isTrue(peerCasted.onConnectCaled);
            }

            async.done();
        });
    }
}
