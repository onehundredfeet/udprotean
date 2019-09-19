package udprotean.shared;

import haxe.io.Bytes;
import sys.net.Address;
import sys.net.Host;
import sys.net.UdpSocket;

class UDProteanSocket
{
    var host: String;
    var port: Int;
    var socket: UdpSocket;

    var recvBuffer: Bytes;
    var recvAddress: Address;

    public function new(host: String, port: Int)
    {
        this.host = host;
        this.port = port;

        socket = new UdpSocket();
        socket.setFastSend(true);
        recvBuffer = Bytes.alloc(1024);
    }

    public function sendTo(buf: Bytes, addr: Address)
    {
        socket.sendTo(buf, 0, buf.length, addr);
    }

    public function receive(): Bytes
    {
        socket.waitForRead();
        var bytesRead: Int = socket.readFrom(recvBuffer, 0, recvBuffer.length, recvAddress);
        return recvBuffer.sub(0, bytesRead);
    }

    public inline function recvFromAddressString(): String
    {
        return recvAddress.host + ":" + recvAddress.port;
    }

    public function bind()
    {
        socket.bind(new Host(host), port);
    }

    public function connect()
    {
        socket.connect(new Host(host), port);
    }

    public function close()
    {
        socket.close();
    }
}
