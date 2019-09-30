package udprotean.server;

import haxe.crypto.Sha1;
import udprotean.shared.Timestamp;
import sys.net.Address;
import udprotean.shared.UDProteanPeer;
import haxe.io.Bytes;
import udprotean.shared.UdpSocketEx;

using udprotean.shared.Utils;


class UDProteanServer
{
    var host: String;
    var port: Int;
    var behaviorType: Class<UDProteanClientBehavior>;

    var started: Bool;
    var socket: UdpSocketEx;
    var peers: Map<String, UDProteanClientBehavior>;


    public function new(host: String, port: Int, behaviorType: Class<UDProteanClientBehavior>)
    {
        this.host = host;
        this.port = port;
        this.behaviorType = behaviorType;
        started = false;
        socket = new UdpSocketEx();
        peers = new Map<String, UDProteanClientBehavior>();
    }


    public function start()
    {
        socket.listen(host, port);
        socket.setBlocking(false);
        started = true;
    }


    public function stop()
    {
        if (started)
            socket.close();
    }


    /**
     * Read and process all incoming datagrams currently available on the socket.
     * The method will only return when there are no available data to read.
     */
    public function update()
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
        var recvFromAddressString: String = socket.recvFromAddressString();

        if (Utils.isHandshake(datagram))
        {
            // Bounce back the handshake code.
            socket.sendTo(datagram, recvFromAddress);

            var handshakeCode: String = datagram.toHex();
            var peerID: String = Utils.generatePeerID(handshakeCode, recvFromAddressString);

            // Add sender to the peers list.
            if (!peers.exists(recvFromAddressString))
            {
                initializePeer(recvFromAddress, peerID);
            }
            return true;
        }

        if (Utils.isDisconnect(datagram))
        {
            var disconnectCode: String = datagram.toHex();
            var peerID: String = Utils.generatePeerID(disconnectCode, recvFromAddressString);

            if (peers.exists(recvFromAddressString))
            {
                var validDisconnectCode: Bool = ( peers[recvFromAddressString].peerID == Utils.generatePeerID(disconnectCode, recvFromAddressString) );

                if (validDisconnectCode)
                {
                    // Bounce back the disconnect code.
                    socket.sendTo(datagram, recvFromAddress);

                    // Remove peer.
                    peers.remove(recvFromAddressString);
                }
            }

            return true;
        }


        if (!peers.exists(recvFromAddressString))
        {
            // Not a handshake datagram and no known peer on that address.
            // Drop it.
            return true;
        }


        var peer: UDProteanPeer = peers.get(recvFromAddressString);
        peer.onReceived(datagram);
        return true;
    }


    function updatePeers()
    {
        for (peer in peers)
        {
            peer.update();
        }
    }


    function initializePeer(peerAddress: Address, peerId: String)
    {
        var peer: UDProteanClientBehavior = Type.createInstance(behaviorType, [socket, peerAddress, peerId]);
        peers.set(peerAddress.addressToString(), peer);
        peer.initialize();
        peer.onConnect();
    }
}
