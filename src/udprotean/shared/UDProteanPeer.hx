package udprotean.shared;

import udprotean.shared.protocol.CommandCode;
import sys.net.Address;
import haxe.io.Bytes;
import udprotean.shared.protocol.SequentialCommunication;


class UDProteanPeer extends SequentialCommunication
{
    @:protected var socket: UdpSocketEx;
    @:protected var peerAddress: Address;
    
    #if UDPROTEAN_UNIT_TEST
    public static var PacketLoss: Float = 0;
    var rand: seedyrng.Random = new seedyrng.Random();
    #end


    function new(socket: UdpSocketEx, peerAddress: Address)
    {
        super();
        this.socket = socket;
        this.peerAddress = peerAddress;
    }


    /**
     * Send an unreliable message. 
     * This message is one that will bypass the sequential communication
     * protocol and be transmitted immediately as a normal UDP datagram.
     * Besides delivery and order of receiving of these messages not being guaranteed,
     * the fragmentation features of this library also do not apply to messages
     * sent through this method, this means that a message size larger than the network's
     * MTU may cause it to get dropped along the way. A recommended maximum message
     * length would be around 540 bytes.
     */
    public final function sendUnreliable(message: Bytes)
    {
        var codeByteLength: Int = CommandCode.UnreliableMessage.getByteLength();
        var datagram: Bytes = Bytes.alloc(message.length + codeByteLength);
        datagram.blit(0, CommandCode.UnreliableMessage.toBytes(), 0, codeByteLength);
        datagram.blit(codeByteLength, message, 0, message.length);
        onTransmit(datagram);
    }


    /**
     * Returns `true` if the peer is currently connected.
     */
    @IgnoreCover
    public final inline function isConnected(): Bool
    {
        return socket.isConnected();
    }


    @:noCompletion
    public override final function onReceived(datagram: Bytes)
    {
        super.onReceived(datagram);
    }

    
    @:noCompletion @:protected
    override final function onTransmit(datagram: Bytes) 
    {
        #if UDPROTEAN_UNIT_TEST
        if (rand.random() >= PacketLoss)
        #end

        socket.sendTo(datagram, peerAddress);
    }

    
    @:noCompletion @:protected
    final override function onMessageReceived(message: Bytes) 
    {
        onMessage(message);
    }

    
    @:noCompletion @:allow(udprotean.server.UDProteanServer)
    final function onUnreliableMessageReceived(datagram: Bytes) 
    {
        var commandCodeLength: Int = CommandCode.UnreliableMessage.getByteLength();
        var message = datagram.sub(commandCodeLength, datagram.length - commandCodeLength);
        onMessage(message);
    }


    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function initialize() { }
    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onConnect() { }
    @IgnoreCover                                           function onMessage(message: Bytes) { }
    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onDisconnect() { }
}
