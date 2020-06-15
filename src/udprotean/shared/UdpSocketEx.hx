package udprotean.shared;

import haxe.io.Bytes;
import sys.net.Address;
import sys.net.Host;

using udprotean.shared.Utils;


class UdpSocketEx
{
    @:private var socket: BaseSocketType;

    var recvBuffer: Bytes;
    var recvAddress: Address;


    public function new()
    {
        socket = new BaseSocketType();
        socket.setBlocking(false);

        recvBuffer = Bytes.alloc(1024);
        recvAddress = new Address();
    }


    public inline function sendTo(buf: Bytes, addr: Address)
    {
        socket.sendTo(buf, 0, buf.length, addr);
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

        while (timestamp.elapsed() < timeout)
        {
            try
            {
                bytesRead = socket.readFrom(recvBuffer, 0, recvBuffer.length, recvAddress);
                return recvBuffer.sub(0, bytesRead);
            }
            catch(e: Dynamic) { }
        }

        return null;
    }


    public function trySendAndRead(buf: Bytes, addr: Address): Bytes
    {
        try
        {
            sendTo(buf, addr);

            return readTimeout(0.010);
        }
        catch (e: Dynamic)
        {
            trace(e);
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


    public function listen(host: String, port: Int)
    {
        socket.bind(new Host(host), port);
    }


    public function connect(host: Host, port: Int)
    {
        socket.connect(host, port);
    }


    public function close()
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
}
