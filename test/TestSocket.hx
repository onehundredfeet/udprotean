import haxe.macro.Expr.Catch;
import haxe.io.Bytes;
import haxe.unit.TestCase;

import sys.net.Address;
import sys.net.Host;

import udprotean.shared.UDProteanSocket;

class TestSocket extends TestCase
{
    var serverAddr: Address;
    var server: UDProteanSocket;
    var client: UDProteanSocket;

    public override function setup()
    {
        serverAddr = new Address();
        serverAddr.host = new Host("127.0.0.1").ip;
        serverAddr.port = 9000;
        server = new  UDProteanSocket("127.0.0.1", 9000);
        client = new UDProteanSocket("127.0.0.1", 9000);

        server.bind();
        client.connect();
    }

    function testBasicSendReceive()
    {
        client.sendTo(Bytes.ofString("ping"), serverAddr);

        var serverRecv = server.receive().toString();
        assertEquals("ping", serverRecv);

        server.sendTo(Bytes.ofString("pong"), server.recvFromAddress());

        var clientRecv = client.receive().toString();
        assertEquals("pong", clientRecv);
    }
}
