package udprotean.client;

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
        var timestamp: Timestamp = new Timestamp();

        socket.connect(serverHost, serverPort);
        
        handshakeCode = Utils.generateHandshake();

        var response: Bytes;
        do
        {
            if (timeout > 0 && timestamp.elapsed() > timeout)
            {
                socket.close();
                return false;
            }

            socket.sendTo(Bytes.ofHex(handshakeCode), peerAddress);

            response = socket.readTimeout(0.0001);
        }
        while (response == null || response.toHex() != handshakeCode);

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
            var response: Bytes;

            do
            {
                socket.sendTo(Bytes.ofHex(disconnectCode), peerAddress);
                response = socket.readTimeout(0.0001);
            }
            while ((response == null || response.toHex() != disconnectCode)
                && !timestamp.isTimedOut(timeout));

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

        if (socket.recvFromAddressString() != peerAddress.addressToString())
        {
            // Received from someone other than the server.
            return true;
        }

        if (Utils.isHandshake(datagram))
        {
            // Clients don't have to bounce handshake messages.
            return true;
        }

        onReceived(datagram);
        return true;
    }
}
