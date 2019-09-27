package udprotean.server;

import sys.net.Address;
import udprotean.shared.UDProteanPeer;
import haxe.io.Bytes;
import udprotean.shared.UdpSocketEx;

using udprotean.shared.Utils;


class UDProteanServer
{
    var host: String;
    var port: Int;
    var behaviorType: Class<UDProteanPeer>;

    var started: Bool;
    var socket: UdpSocketEx;
    var peers: Map<String, UDProteanPeer>;


    public function new(host: String, port: Int, behaviorType: Class<UDProteanPeer>)
    {
        this.host = host;
        this.port = port;
        this.behaviorType = behaviorType;
        started = false;
        socket = new UdpSocketEx();
        peers = new Map<String, UDProteanPeer>();
    }


    public function start()
    {
        socket.listen(host, port);
        started = true;
    }


    public function stop()
    {
        if (started)
            socket.close();
    }


    public function update()
    {
        processRead();
        
        updatePeers();
    }


    function processRead()
    {
        // Attempt to read available data.
        var datagram: Bytes = socket.readTimeout(0.001);

        if (datagram == null)
        {
            // Nothing to read.
            return;
        }

        var recvFromAddress: Address = socket.recvFromAddress();
        var recvFromAddressString: String = socket.recvFromAddressString();


        if (Utils.isHandshake(datagram))
        {
            // Bounce back the handshake code.
            socket.sendTo(datagram, recvFromAddress);

            // Add sender to the peers list.
            if (!peers.exists(recvFromAddressString))
            {
                initializePeer(recvFromAddress);
            }
            return;
        }


        if (!peers.exists(recvFromAddressString))
        {
            // Not a handshake datagram and no known peer on that address.
            // Drop it.
            return;
        }


        var peer: UDProteanPeer = peers.get(recvFromAddressString);
        peer.onReceived(datagram);
    }


    function updatePeers()
    {
        for (peer in peers)
        {
            peer.update();
        }
    }


    function initializePeer(peerAddress: Address)
    {
        var peer: UDProteanPeer = Type.createInstance(behaviorType, [socket, peerAddress]);
        peers.set(peerAddress.addressToString(), peer);
        peer.initialize();
        peer.onConnect();
    }
}
