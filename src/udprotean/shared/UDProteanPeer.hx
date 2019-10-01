package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;
import udprotean.shared.protocol.SequentialCommunication;


class UDProteanPeer extends SequentialCommunication
{
    @:protected var socket: UdpSocketEx;
    @:protected var peerAddress: Address;
    #if UNIT_TEST
    public static var PacketLoss: Float = 0;
    var rand: seedyrng.Random = new seedyrng.Random();
    #end


    function new(socket: UdpSocketEx, peerAddress: Address)
    {
        super();
        this.socket = socket;
        this.peerAddress = peerAddress;
    }


    public override function update() 
    {
        super.update();
    }


    @IgnoreCover
    public final inline function isConnected(): Bool
    {
        return socket.isConnected();
    }


    @:noCompletion
    public override final function onReceived(datagram: Bytes)
    {
        if (Utils.isHandshake(datagram))
        {
            return;
        }
        
        super.onReceived(datagram);
    }

    
    @:noCompletion @:protected
    override final function onTransmit(message: Bytes) 
    {
        #if UNIT_TEST
        if (rand.random() >= PacketLoss)
        #end

        socket.sendTo(message, peerAddress);
    }

    
    @:noCompletion @:protected
    final override function onMessageReceived(message: Bytes) 
    {
        onMessage(message);
    }


    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function initialize() { }
    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onConnect() { }
    @IgnoreCover                                           function onMessage(message: Bytes) { }
    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onDisconnect() { }
}
