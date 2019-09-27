package udprotean.shared;

import haxe.io.Bytes;
import sys.net.Address;
import sys.net.Host;
import sys.net.UdpSocket;

using udprotean.shared.Utils;

class UdpSocketEx
{
    var host: Host;
    var port: Int;

    var socket: UdpSocket;

    var recvBuffer: Bytes;
    var recvAddress: Address;
    

    public function new()
    {
        socket = new UdpSocket();
        socket.setBlocking(false);

        recvBuffer = Bytes.alloc(1024);
        recvAddress = new Address();
    }


    public function send(buf: Bytes)
    {
        socket.output.writeFullBytes(buf, 0, buf.length);
    }


    public function sendTo(buf: Bytes, addr: Address)
    {
        socket.sendTo(buf, 0, buf.length, addr);
    }


    public function receive(): Bytes
    {
        socket.waitForRead();
        return read();
    }


    public function read(): Bytes
    {
        try
        {
            var bytesRead: Int = socket.readFrom(recvBuffer, 0, recvBuffer.length, recvAddress);
            return recvBuffer.sub(0, bytesRead);
        }
        catch (e: Dynamic)
        {
            return null;
        }
    }


    /**
     * Attempt to read from the socket for a given timeout in seconds,
     * returning `null` is nothing is read.
     */
    public function readTimeout(timeout: Float): Bytes
    {
        var bytesRead: Int = 0;
        var timestamp: Timestamp = new Timestamp();

        while (bytesRead == 0 && timestamp.elapsed() < timeout)
        {
            try
            {
                bytesRead = socket.readFrom(recvBuffer, 0, recvBuffer.length, recvAddress);
            }
            catch(e: Dynamic) { }
            
            if (bytesRead > 0)
            {
                return recvBuffer.sub(0, bytesRead);
            }
        }

        return null;
    }


    public inline function recvFromAddress(): Address
    {
        return recvAddress;
    }


    public inline function recvFromAddressString(): String
    {
        return recvAddress.addressToString();
    }


    public function listen(host: String, port: Int)
    {
        setHost(host, port);
        socket.bind(new Host(host), port);
    }


    public function connect(host: String, port: Int)
    {
        setHost(host, port);
        socket.connect(new Host(host), port);
    }


    public inline function close()
    {
        socket.close();
    }


    public function isConnected(): Bool
    {
        try
        {
            return socket.peer() != null;
        }
        catch (e: Dynamic) { }
        return false;
    }


    public inline function setBlocking(blocking: Bool)
    {
        socket.setBlocking(blocking);
    }


    inline function setHost(host: String, port: Int)
    {
        this.host = new Host(host);
        this.port = port;
    }
}
