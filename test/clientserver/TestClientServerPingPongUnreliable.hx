package clientserver;

import seedyrng.Seedy;
import udprotean.shared.protocol.UDProteanConfiguration;
import udprotean.shared.UDProteanPeer;
import udprotean.shared.protocol.SequentialCommunication;
import sys.thread.Thread;
import haxe.Timer;
import utest.Async;
import clientserver.models.TestPingPongClientUnreliable;
import clientserver.models.TestPingPongClientBehaviorUnreliable;
import udprotean.client.UDProteanClient;
import udprotean.server.UDProteanServer;
import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

class TestClientServerPingPongUnreliable implements ITest
{
    final ServerUpdates = 1000;

    var server: UDProteanServer;
    var client: TestPingPongClientUnreliable;


    public function new() { }


    function setup()
    {
        var port: Int = Seedy.randomInt(1025, 65535);
        server = new UDProteanServer("127.0.0.1", port, TestPingPongClientBehaviorUnreliable);
        client = new TestPingPongClientUnreliable("127.0.0.1", port);
    }


    function teardown()
    {
        client.disconnect();
        server.stop();
        UDProteanPeer.PacketLoss = 0;
    }

#if !cpp
    @:timeout(10000)
    function testSendUnreliable(async: Async)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();
        
        runServer().sendMessage(serverBranch);

        var connected = client.connectTimeout(0.5);

        Assert.isTrue(connected);

        for (_ in 0...100)
        {
            client.sendInt(127);
            client.update();
        }

        while (!serverBranch.resolved) { }

        Assert.equals(127, client.received);

        clientBranch.done();
    }
#end

    function runServer(): Thread
    {
        return Thread.create(() -> {

            var branch: Async = cast Thread.readMessage(true);
            
            server.start();

            for (_ in 0...ServerUpdates)
            {
                server.update();
            }

            branch.done();
        });
    }
}
