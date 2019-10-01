package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;
import udprotean.shared.protocol.SequentialCommunication;


class UDProteanPeer extends SequentialCommunication
{
    @:private var socket: UdpSocketEx;
    @:private var peerAddress: Address;
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


    @:private
    override function update() 
    {
        super.update();
    }


    @IgnoreCover
    public final inline function isConnected()
    {
        return socket.isConnected();
    }


    @:noCompletion @:protected
    override final function onReceived(datagram: Bytes)
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

    
    @:noCompletion @:private
    final override function onMessageReceived(message: Bytes) 
    {
        onMessage(message);
    }


    @:protected @IgnoreCover @:allow(udprotean.server.UDProteanServer) function initialize() { }
    @:protected @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onConnect() { }
    @:protected @IgnoreCover                                           function onMessage(message: Bytes) { }
    @:protected @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onDisconnect() { }
}
