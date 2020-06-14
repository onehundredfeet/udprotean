package udprotean.server;

import udprotean.shared.protocol.CommandCode;
import haxe.crypto.Sha1;
import udprotean.shared.Timestamp;
import sys.net.Address;
import udprotean.shared.UDProteanPeer;
import haxe.io.Bytes;
import udprotean.shared.UdpSocketEx;

using udprotean.shared.Utils;


class UDProteanServer
{
    @:private var host: String;
    @:private var port: Int;
    @:private var behaviorType: Class<UDProteanClientBehavior>;

    @:private var started: Bool;
    @:private var socket: UdpSocketEx;
    @:private var peers: Map<Int, UDProteanClientBehavior>;


    public function new(host: String, port: Int, behaviorType: Class<UDProteanClientBehavior>)
    {
        this.host = host;
        this.port = port;
        this.behaviorType = behaviorType;
        started = false;
        socket = new UdpSocketEx();
        peers = new Map();
    }


    /**
     * Starts the server.
     * Essentially only binds the UDP port.
    */
    public function start()
    {
        socket.listen(host, port);
        socket.setBlocking(false);
        started = true;
    }


    /**
     * Stops the server and closes the socket.
     */
    public function stop()
    {
        if (started)
            socket.close();
    }


    /**
     * Read and process all incoming datagrams currently available on the socket.
     * The method will only return when there are no available data to read.
     */
    public inline function update()
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
        var timestamp: Timestamp = new Timestamp();
        var hadDatagrams: Bool;

        do
        {
            hadDatagrams = processRead();

            updatePeers();
        }
        while (hadDatagrams && !timestamp.isTimedOut(timeout));
    }


    @:private
    function processRead(): Bool
    {
        // Attempt to read available data.
        var datagram: Bytes = socket.readTimeout(0.001);

        if (datagram == null)
        {
            // Nothing to read.
            return false;
        }

        var recvFromAddress: Address = socket.recvFromAddress();
        var recvFromAddressId: Int = socket.recvFromAddressId();
        var commandCode: CommandCode = CommandCode.ofBytes(datagram);

        var peer: UDProteanClientBehavior = peers[recvFromAddressId];

        switch (commandCode)
        {
            case CommandCode.Handshake:
                handleHandshake(datagram, recvFromAddress);


            case CommandCode.Disconnect:
                handleDisconnect(datagram, recvFromAddress);


            case CommandCode.UnreliableMessage if (peer != null):
                peer.onUnreliableMessageReceived(datagram);


            case _ if (peer != null):
                peer.onReceived(datagram);


            case _:
            // Necessary on Neko for some reason.
            // If not present, execution of the method will abruptly stop at the beginning of the switch.
        }

        return true;
    }


    @:private
    function handleHandshake(datagram: Bytes, recvFromAddress: Address)
    {
        // Bounce back the handshake code.
        socket.sendTo(datagram, recvFromAddress);

        var handshakeCode: String = datagram.toHex();
        var peerID: String = Utils.generatePeerID(handshakeCode, recvFromAddress.addressToId());

        // Add sender to the peers list.
        if (!peers.exists(recvFromAddress.addressToId()))
        {
            initializePeer(recvFromAddress, peerID);
        }
    }


    @:private
    function handleDisconnect(datagram: Bytes, recvFromAddress: Address)
    {
        var recvFromAddressId: Int = recvFromAddress.addressToId();

        // Bounce back the disconnect code.
        try
        {
            socket.sendTo(datagram, recvFromAddress);
        }
        catch (e: Dynamic) { }

        var disconnectCode: String = datagram.toHex();
        var peerID: String = Utils.generatePeerID(disconnectCode, recvFromAddressId);

        if (peers.exists(recvFromAddressId))
        {
            var validDisconnectCode: Bool = ( peers[recvFromAddressId].peerID == peerID );

            if (validDisconnectCode)
            {
                // Call the onDisconnect callback.
                peers[recvFromAddressId].onDisconnect();

                // Remove peer.
                peers.remove(recvFromAddressId);
            }
        }
    }


    @:private
    function updatePeers()
    {
        for (peer in peers)
        {
            peer.update();
        }
    }


    @:private
    function initializePeer(peerAddress: Address, peerId: String)
    {
        peerAddress = peerAddress.clone();

        var peer: UDProteanClientBehavior = Type.createInstance(behaviorType, [socket, peerAddress, peerId]);
        peers.set(peerAddress.addressToId(), peer);
        peer.initialize();
        peer.onConnect();
    }
}
