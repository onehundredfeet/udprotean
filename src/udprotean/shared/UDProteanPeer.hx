package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;
import udprotean.shared.protocol.SequentialCommunication;


class UDProteanPeer extends SequentialCommunication
{
    var socket: UdpSocketEx;
    var peerAddress: Address;
    #if UNIT_TEST
    public static var PacketLoss: Float = 0;
    var rand: seedyrng.Random = new seedyrng.Random();
    #end


    public function new(socket: UdpSocketEx, peerAddress: Address)
    {
        super();
        this.socket = socket;
        this.peerAddress = peerAddress;
    }


    public final inline function isConnected()
    {
        return socket.isConnected();
    }


    @:noCompletion
    override final function onReceived(datagram: Bytes)
    {
        if (Utils.isHandshake(datagram))
        {
            return;
        }
        
        super.onReceived(datagram);
    }

    
    @:noCompletion
    override final function onTransmit(message: Bytes) 
    {
        #if UNIT_TEST
        if (rand.random() >= PacketLoss)
        #end

        socket.sendTo(message, peerAddress);
    }

    
    @:noCompletion
    final override function onMessageReceived(message: Bytes) 
    {
        onMessage(message);
    }


    @:allow(udprotean.server.UDProteanServer) function initialize() { }
    @:allow(udprotean.server.UDProteanServer) function onConnect() { }
    function onMessage(message: Bytes) { }
}
