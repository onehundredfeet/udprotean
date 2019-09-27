package clientserver;

import clientserver.models.TestConnectClient;
import clientserver.models.TestConnectClientBehavior;
import udprotean.client.UDProteanClient;
import udprotean.server.UDProteanServer;
import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;


class TestClientServerConnect implements ITest
{
    var server: UDProteanServer;
    var client: TestConnectClient;


    public function new()
    {

    }


    function setup()
    {
        server = new UDProteanServer("127.0.0.1", 9000, TestConnectClientBehavior);
        client = new TestConnectClient("127.0.0.1", 9000);
    }


    function teardown()
    {
        server.stop();
        client.disconnect();
    }


    function testNotConnect()
    {
        server.start();
        var connected: Bool = client.connectTimeout(0.3);

        Assert.isTrue(client.initializeCalled);
        Assert.isFalse(client.onConnectCaled);
        Assert.isFalse(connected);
    }
}
