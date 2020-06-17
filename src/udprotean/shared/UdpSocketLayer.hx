package udprotean.shared;

import haxe.io.Bytes;
import sys.net.Address;
import sys.net.Host;

using udprotean.shared.Utils;


class UdpSocketLayer
{
    var socket: BaseSocketType;

    var recvBuffer: Bytes;
    var recvAddress: Address;
    var error: Dynamic;

    var connected: Bool;


    public function new()
    {
        socket = new BaseSocketType();
        socket.setBlocking(false);

        recvBuffer = Bytes.alloc(1024);
        recvAddress = new Address();
        connected = false;
    }


    public inline function sendToPeer(buf: Bytes)
    {
        socket.writeBytes(buf, 0, buf.length);
    }


    public inline function send(buf: Bytes, addr: Address)
    {
        socket.sendTo(buf, 0, buf.length, addr);
    }


    public inline function read(): Bytes
    {
        error = null;
        try
        {
            var bytesRead: Int = socket.readFrom(recvBuffer, 0, recvBuffer.length, recvAddress);
            return recvBuffer.sub(0, bytesRead);
        }
        catch (e: Dynamic)
        {
            error = e;
            return null;
        }
    }


    /**
     * Attempt to read from the socket for a given timeout in seconds,
     * returning `null` is nothing is read.
     */
    public function readTimeout(timeout: Float): Bytes
    {
        var timestamp: Timestamp = new Timestamp();
        var data: Bytes = null;

        while (data == null && timestamp.elapsed() < timeout)
        {
            data = read();
        }

        return data;
    }


    public function readFromPeer(): Bytes
    {
        error = null;
        try
        {
            var bytesRead: Int = socket.readBytes(recvBuffer, 0, recvBuffer.length);
            return recvBuffer.sub(0, bytesRead);
        }
        catch (e: Dynamic)
        {
            error = e;
            return null;
        }
    }


    /**
     * Attempt to read from the socket for a given timeout in seconds,
     * returning `null` is nothing is read.
     */
    public function readFromPeerTimeout(timeout: Float): Bytes
    {
        var timestamp: Timestamp = new Timestamp();
        var data: Bytes = null;

        while (data == null && timestamp.elapsed() < timeout)
        {
            data = readFromPeer();
        }

        return data;
    }


    public function trySendAndRead(buf: Bytes, addr: Address): Bytes
    {
        try
        {
            send(buf, addr);

            return readTimeout(0.010);
        }
        catch (e: Dynamic)
        {
            error = e;
            return null;
        }
    }


    public function trySendToPeerAndRead(buf: Bytes): Bytes
    {
        try
        {
            sendToPeer(buf);

            return readFromPeerTimeout(0.010);
        }
        catch (e: Dynamic)
        {
            return null;
        }
    }


    public inline function recvFromAddress(): Address
    {
        return recvAddress;
    }


    public inline function recvFromAddressId(): Int
    {
        return recvAddress.addressToId();
    }


    public inline function listen(host: String, port: Int)
    {
        socket.bind(new Host(host), port);
    }


    public inline function connect(host: Host, port: Int)
    {
        socket.connect(host, port);
        recvAddress.host = host.ip;
        recvAddress.port = port;
        connected = true;
    }


    public inline function close()
    {
        socket.close();
        recvAddress.host = 0;
        recvAddress.port = 0;
        connected = false;
    }


    public inline function isConnected(): Bool
    {
        return connected;
    }


    public inline function setBlocking(blocking: Bool)
    {
        socket.setBlocking(blocking);
    }


    public inline function getPeer(): { host: Host, port: Int }
    {
        return socket.peer();
    }
}
