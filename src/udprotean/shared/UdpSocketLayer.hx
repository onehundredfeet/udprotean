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


    /**
     * Sends a datagram to the connected peer.
     *
     * @param buf The datagram to send.
     */
    public inline function sendToPeer(buf: Bytes)
    {
        socket.writeBytes(buf, 0, buf.length);
    }


    /**
     * Sends a datagram to a specific address.
     *
     * @param buf The datagram to send.
     * @param addr The address to send to.
     */
    public inline function send(buf: Bytes, addr: Address)
    {
        socket.sendTo(buf, 0, buf.length, addr);
    }


    /**
     * Attempts to read a datagram on the socket from any address.
     * If reading was successful, `recvFromAddress()` may be used to retrieve the address
     * it was received from.
     *
     * @return The datagram that was read, or `null` if nothing was available on the socket.
     */
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
     * Attempt to read from the socket for a given timeout in seconds.
     * If reading was successful, `recvFromAddress()` may be used to retrieve the address
     * it was received from.
     *
     * @param timeout The time to attempt to read for, in seconds.
     * @return The datagram that was read, or `null` if nothing was available on the socket.
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

    /**
     * Attempts to read a datagram on the socket from the connected peer.
     *
     * @return The datagram that was read, or `null` if nothing was available on the socket.
     */
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
     * Attempt to read on the socket from the connected peer, for a given timeout in seconds.
     *
     * @param timeout The time to attempt to read for, in seconds.
     * @return The datagram that was read, or `null` if nothing was available on the socket.
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


    /**
     * Sends a datagram to a given address, and then attempts to read a response on the socket.
     *
     * @param buf The datagram to send.
     * @param addr The address to send to.
     * @return The datagram that was read, or `null` if nothing was available on the socket.
     */
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


    /**
     * Sends a datagram to the connected peer, and then attempts to read a response on the socket.
     *
     * @param buf The datagram to send.
     * @param addr The address to send to.
     * @return The datagram that was read, or `null` if nothing was available on the socket.
     */
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


    /**
     * Gets the address from which the last datagram was received from.
     */
    public inline function recvFromAddress(): Address
    {
        return recvAddress;
    }


    /**
     * Gets the numeric id for the address from which the last datagram was received from.
     */
    public inline function recvFromAddressId(): Int
    {
        return recvAddress.addressToId();
    }


    /**
     * Binds the socket to the given IP address and port.
     *
     * @param host The host to bind the socket to.
     * The wildcard would be `0.0.0.0` or `*` depending on the platform.
     * @param port The port to bind the socket to.
     */
    public inline function listen(host: String, port: Int)
    {
        socket.bind(new Host(host), port);
    }


    /**
     * Connects the socket to the given address.
     *
     * While connected, `readFromPeer()` and `sendToPeer()` should be used,
     * instead of `read()` and `send()`.
     *
     * @param host The host to the connect to.
     * @param port The port to connect to.
     */
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
