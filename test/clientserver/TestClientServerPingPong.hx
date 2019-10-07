package clientserver;

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
        server = new UDProteanServer("127.0.0.1", 9000, TestPingPongClientBehavior);
        client = new TestPingPongClient("127.0.0.1", 9000);
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


    @:timeout(100000)
    function testPingPongPacketLoss(async: Async)
    {
        UDProteanPeer.PacketLoss = 0.1;
        doTest(async, 20000);
    }
    

    function doTest(async: Async, updates: Int)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        var serverThread = Thread.create(() -> {

            var branch: Async = cast Thread.readMessage(true);
            
            server.start();

            var shouldStop: Bool = false;

            do
            {
                server.update();

                shouldStop = Thread.readMessage(false) != null;

            } while(!shouldStop);

            branch.done();
        });

        serverThread.sendMessage(serverBranch);
        
        var connected: Bool = client.connectTimeout(0.5);

        Assert.isTrue(connected);

        client.sendInt(0);

        for (_ in 0...updates)
        {
            client.update();
        }

        serverThread.sendMessage(true);

        Assert.equals(Count, client.expected);

        clientBranch.done();
    }
}
