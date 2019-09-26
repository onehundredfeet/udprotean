package udprotean;

import haxe.io.Bytes;
import sys.net.Host;
import sys.net.Address;
import udprotean.shared.UdpSocketEx;
import udprotean.shared.UDProteanPeer;


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

    
    public final function connect()
    {
        socket.connect(peerAddress.getHost().host, peerAddress.port);
        
        var response: Bytes;
        do
        {
            socket.send(Bytes.ofHex("FFFFFFFF"));

            response = socket.readTimeout(0.5);
        }
        while (response == null || response.toHex() != "FFFFFFFF");

        onConnect();
    }


    final override function onMessageReceived(message: Bytes) 
    {
        onMessage(message);
    }


    function initialize() { }
    function onConnect() { }
    function onMessage(message: Bytes) { }
}