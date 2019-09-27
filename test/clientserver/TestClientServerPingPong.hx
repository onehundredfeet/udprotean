package clientserver;

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
    final Count = SequentialCommunication.SequenceSize * 4;
    final Updates = 10000;

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
        server.stop();
        client.disconnect();
    }


    @:timeout(20000)
    function testPingPong(async: Async)
    {
        var clientBranch = async.branch();
        var serverBranch = async.branch();

        Thread.create(() -> {
            
            server.start();

            for (_ in 0...Updates)
            {
                server.update();
            }

            serverBranch.done();
        });
        
        var connected: Bool = client.connectTimeout(0.5);

        Assert.isTrue(connected);

        client.sendInt(0);

        for (_ in 0...Updates)
        {
            client.update();
        }

        Assert.equals(Count, client.expected);

        clientBranch.done();
    }
}
