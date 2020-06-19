package clientserver;

import udprotean.shared.protocol.UDProteanConfiguration;
import udprotean.server.UDProteanClientBehavior;
import seedyrng.Seedy;
import udprotean.shared.Utils;
import udprotean.shared.UDProteanPeer;
import sys.thread.Thread;
import utest.Async;
import clientserver.models.TestConnectClient;
import clientserver.models.TestConnectClientBehavior;
import udprotean.client.UDProteanClient;
import udprotean.server.UDProteanServer;
import utest.ITest;
import utest.Assert;


@:access(udprotean.server.UDProteanServer)
@:access(udprotean.client.UDProteanClient)
class TestClientServerConnect implements ITest
{
    final ServerUpdates = 1000;

    var port: Int;
    var server: UDProteanServer;
    var client: TestConnectClient;
    var clients: Array<UDProteanClient>;

    var onConnectedCalledCounter: Int;
    var onDisconnectedCalledCounter: Int;


    public function new() { }


    function setup()
    {
        UDProteanPeer.PacketLoss = 0;
        onConnectedCalledCounter = 0;
        onDisconnectedCalledCounter = 0;

        port = Seedy.randomInt(1025, 65535);
        server = new UDProteanServer("127.0.0.1", port, TestConnectClientBehavior);
        server.onClientConnected(onClientConnectedCallback);
        server.onClientDisconnected(onClientDisconnectedCallback);
        client = new TestConnectClient("127.0.0.1", port);
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
        Assert.equals(0, onConnectedCalledCounter);
    }


    @:timeout(20000)
    function testConnect(async: Async)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        var onDone = () ->
        {
            Assert.equals(1, onConnectedCalledCounter);
            Assert.equals(0, onDisconnectedCalledCounter);
        };

        runServer(1, onDone).sendMessage(serverBranch);

        var connected: Bool = client.connectTimeout(0.5);

        Assert.isTrue(client.initializeCalled);
        Assert.isTrue(client.onConnectCaled);
        Assert.isTrue(connected);

        clientBranch.done();
    }


    @:timeout(20000)
    function testConnectMultiple(async: Async)
    {
        UDProteanPeer.PacketLoss = 0.1;

        var numOfClients = 16;
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        var onDone = () ->
        {
            Assert.equals(numOfClients, onConnectedCalledCounter);
            Assert.equals(0, onDisconnectedCalledCounter);
        };

        runServer(numOfClients, onDone).sendMessage(serverBranch);

        for (_ in 0...numOfClients)
        {
            var client = new TestConnectClient("127.0.0.1", port);
            clients.push(client);

            var connected = client.connectTimeout(0.5);

            Assert.isTrue(client.isConnected());
            Assert.isTrue(client.initializeCalled);
            Assert.isTrue(client.onConnectCaled);
            Assert.isFalse(client.onDisconnectCalled);
            Assert.isTrue(connected);
        }

        clientBranch.done();
    }


    @:timeout(20000)
    function testDisconnect(async: Async)
    {
        var numOfClients = 16;
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        var onDone = () ->
        {
            Assert.equals(numOfClients, onConnectedCalledCounter);
            Assert.equals(numOfClients, onDisconnectedCalledCounter);
        };

        runServer(0, onDone).sendMessage(serverBranch);

        for (i in 0...numOfClients)
        {
            var client = new TestConnectClient("127.0.0.1", port);
            clients.push(client);

            var connected = client.connectTimeout(1);

            Assert.isTrue(client.isConnected());
            Assert.isTrue(client.initializeCalled);
            Assert.isTrue(client.onConnectCaled);
            Assert.isFalse(client.onDisconnectCalled);
            Assert.isTrue(connected);

            client.disconnect(0.5);

            Assert.isTrue(client.onDisconnectCalled);
        }

        clientBranch.done();
    }


    @:timeout(20000)
    function testDisconnectIdle(async: Async)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        runServer(1).sendMessage(serverBranch);

        var client = new TestConnectClient("127.0.0.1", port);
        clients.push(client);

        var connected = client.connectTimeout(1);

        Assert.isTrue(client.isConnected());
        Assert.isTrue(client.initializeCalled);
        Assert.isTrue(client.onConnectCaled);
        Assert.isFalse(client.onDisconnectCalled);
        Assert.isTrue(connected);

        // Sleep until client is considered idle.
        Sys.sleep(UDProteanConfiguration.ClientIdleTimeLimit + 1);

        Assert.isTrue(server.peers.iterator().next().getLastReceivedElapsed() > UDProteanConfiguration.ClientIdleTimeLimit);

        server.updatePeers();

        Assert.equals(0, Lambda.count(server.peers));

        clientBranch.done();
    }


    @:timeout(10000)
    function testInvalidDisconnect(async: Async)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        // Expect one connected client at the end.
        runServer(1).sendMessage(serverBranch);

        var connected = client.connectTimeout(0.5);
        Assert.isTrue(client.initializeCalled);
        Assert.isTrue(client.onConnectCaled);
        Assert.isFalse(client.onDisconnectCalled);
        Assert.isTrue(connected);

        // Alter the initial handshake code so that disconnect fails.
        client.handshakeCode = Utils.generateHandshake();

        client.disconnect();

        // onDisconnect should have been called regardless of the server.
        Assert.isTrue(client.onDisconnectCalled);

        clientBranch.done();
    }


    function runServer(expectedPeerCount: Int, onDone: () -> Void = null): Thread
    {
        return Thread.create(() -> {

            var branch: Async = cast Thread.readMessage(true);

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

            if (onDone != null)
            {
                onDone();
            }

            branch.done();
        });
    }


    function onClientConnectedCallback(client: UDProteanClientBehavior)
    {
        onConnectedCalledCounter++;
    }


    function onClientDisconnectedCallback(client: UDProteanClientBehavior)
    {
        onDisconnectedCalledCounter++;
    }
}
