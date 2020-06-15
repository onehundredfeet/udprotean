package clientserver;

import seedyrng.Seedy;
import udprotean.shared.protocol.UDProteanConfiguration;
import udprotean.shared.UDProteanPeer;
import udprotean.shared.protocol.SequentialCommunication;
import sys.thread.Thread;
import haxe.Timer;
import utest.Async;
import clientserver.models.TestPingPongClient;
import clientserver.models.TestPingPongClientBehavior;
import udprotean.client.UDProteanClient;
import udprotean.server.UDProteanServer;
import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

class TestClientServerPingPong implements ITest
{
    final Count = UDProteanConfiguration.SequenceSize * 2;

    var server: UDProteanServer;
    var client: TestPingPongClient;


    public function new() { }


    function setup()
    {
        var port: Int = Seedy.randomInt(1025, 65535);
        server = new UDProteanServer("127.0.0.1", port, TestPingPongClientBehavior);
        client = new TestPingPongClient("127.0.0.1", port);
        client.count = Count;
    }


    function teardown()
    {
        client.disconnect();
        server.stop();
        UDProteanPeer.PacketLoss = 0;
    }


    @:timeout(100000)
    function testPingPong(async: Async)
    {
        doTest(async, 10000);
    }


    @:timeout(120000)
    function testPingPongPacketLoss(async: Async)
    {
        UDProteanPeer.PacketLoss = 0.1;
        doTest(async, 30000);
    }


    function doTest(async: Async, updates: Int)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        var serverThread = Thread.create(() -> {

            var branch: Async = cast Thread.readMessage(true);

            server.start();

            for (_ in 0...updates)
            {
                server.update();
            }

            branch.done();
        });

        serverThread.sendMessage(serverBranch);

        var connected: Bool = client.connectTimeout(1);

        Assert.isTrue(connected);

        client.sendInt(0);

        for (_ in 0...updates)
        {
            client.update();
        }

        Assert.equals(Count, client.expected);

        clientBranch.done();
    }
}
