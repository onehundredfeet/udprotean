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
    public final function new(serverHost: String, serverPort: Int)
    {
        var socket: UdpSocketEx = new UdpSocketEx();
        var serverAddress = new Address();
        serverAddress.host = new Host(serverHost).ip;
        serverAddress.port = serverPort;
        
        super(socket, serverAddress);

        initialize();
    }


    public final override function update()
    {
        super.update();

        processRead();
    }


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

        socket.connect(peerAddress.getHost().host, peerAddress.port);
        
        var handshakeCode: String = Utils.generateHandshake();
        var response: Bytes;
        do
        {
            if (timeout > 0 && timestamp.elapsed() > timeout)
            {
                socket.close();
                return false;
            }

            socket.sendTo(Bytes.ofHex(handshakeCode), peerAddress);

            response = socket.readTimeout(0.001);
        }
        while (response == null || response.toHex() != handshakeCode);

        onConnect();
        return true;
    }
    

    public final inline function disconnect()
    {
        if (socket.isConnected())
        {
            socket.close();
        }
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

        if (socket.recvFromAddressString() != peerAddress.addressToString())
        {
            // Received from someone other than the server.
            return;
        }

        if (Utils.isHandshake(datagram))
        {
            // Clients don't have to bounce handshake messages.
            return;
        }

        onReceived(datagram);
    }
}
