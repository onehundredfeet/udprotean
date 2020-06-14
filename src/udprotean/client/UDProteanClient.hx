package udprotean.client;

import udprotean.shared.protocol.CommandCode;
import udprotean.shared.Timestamp;
import haxe.io.Bytes;
import sys.net.Host;
import sys.net.Address;
import udprotean.shared.UdpSocketEx;
import udprotean.shared.UDProteanPeer;

using udprotean.shared.Utils;


class UDProteanClient extends UDProteanPeer
{
    @:private var serverHost: Host;
    @:private var serverPort: Int;
    @:private var handshakeCode: String;


    @:protected
    public final function new(serverHost: String, serverPort: Int)
    {
        this.serverHost = new Host(serverHost);
        this.serverPort = serverPort;

        var socket: UdpSocketEx = new UdpSocketEx();
        var serverAddress = new Address();
        serverAddress.host = new Host(serverHost).ip;
        serverAddress.port = serverPort;

        super(socket, serverAddress);

        initialize();
    }

    /**
     * Read and process all incoming datagrams currently available on the socket.
     * The method will only return when there are no available data to read.
     */
    public final override function update()
    {
        updateTimeout(0);
    }

    /**
     * Read and process all incoming datagrams currently available on the socket,
     * for a maximum time of the given `timeout`.
     * A `timeout` of `0` means infinite and the method will never return as long
     * as there are available data to read.
     */
    public function updateTimeout(timeout: Float)
    {
        super.update();

        var timestamp: Timestamp = new Timestamp();
        var hadDatagrams: Bool;

        do
        {
            hadDatagrams = processRead();
        }
        while (hadDatagrams && !timestamp.isTimedOut(timeout));
    }


    /**
     * Connect to the server.
     * This method will block and repeatedly try to connect to the server.
     * To attempt to connect for only a specified time, use `connectTimeout()`.
     */
    @IgnoreCover
    public final inline function connect()
    {
        connectTimeout(0);
    }


    /**
     * Attempt to connect to the server for the given time in seconds.
     */
    public final function connectTimeout(timeout: Float): Bool
    {
        initSequentialCommunication();

        var timestamp: Timestamp = new Timestamp();

        socket.connect(serverHost, serverPort);

        handshakeCode = Utils.generateHandshake();

        var response: Bytes = null;
        while (response == null || response.toHex() != handshakeCode)
        {
            if (timestamp.isTimedOut(timeout))
            {
                socket.close();
                return false;
            }

            response = socket.trySendAndRead(Bytes.ofHex(handshakeCode), peerAddress);
        }

        onConnect();

        return true;
    }


    /**
     * Disconnect from the server and close the socket.
     * This method will try to wait until the server acknowledges the disconnect,
     * for an amount of time up until the given `timeout` in seconds.
     */
    public final function disconnect(timeout: Float = 0.3)
    {
        if (socket.isConnected())
        {
            var disconnectCode: String = Utils.getDisconnectCode(handshakeCode);
            var timestamp: Timestamp = new Timestamp();
            var response: Bytes = null;

            while ((response == null || response.toHex() != disconnectCode)
                && !timestamp.isTimedOut(timeout))
            {
                response = socket.trySendAndRead(Bytes.ofHex(disconnectCode), peerAddress);
            }

            socket.close();

            onDisconnect();
        }
    }


    @:noCompletion @:private
    final function processRead(): Bool
    {
        // Attempt to read available data.
        var datagram: Bytes = socket.readTimeout(0.001);

        if (datagram == null)
        {
            // Nothing to read.
            return false;
        }

        if (socket.recvFromAddressId() != peerAddress.addressToId())
        {
            // Received from someone other than the server.
            return true;
        }

        var commandCode: CommandCode = CommandCode.ofBytes(datagram);

        switch (commandCode)
        {
            case CommandCode.Handshake:
                // Clients don't have to bounce handshake messages.


            case CommandCode.Disconnect:
                // Do nothing, probably a bounce.
                // Although if we issued a disconnect we probably shouldn't be calling update() anymore.


            case CommandCode.UnreliableMessage:
                onUnreliableMessageReceived(datagram);


            case _:
                onReceived(datagram);
        }

        return true;
    }
}
