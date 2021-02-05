package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;
import udprotean.client.ClientUdpSocket;
import udprotean.server.ServerUdpSocket;
import udprotean.shared.protocol.CommandCode;
import udprotean.shared.protocol.SequentialCommunication;


class UDProteanPeer extends SequentialCommunication
{
    @:protected var socket: ClientUdpSocket;
    @:protected var peerAddress: Address;
    var lastReceived: Timestamp;
    var lastTransmitted: Timestamp;

    #if UDPROTEAN_UNIT_TEST
    public static var PacketLoss: Float = 0;
    var rand: seedyrng.Random = new seedyrng.Random();
    #end


    function new(socket: ClientUdpSocket, peerAddress: Address)
    {
        super();
        this.socket = socket;
        this.peerAddress = peerAddress;
        lastReceived = Timestamp.Now;
        lastTransmitted = Timestamp.Now;
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
        resetLastReceivedTimestamp();

        super.onReceived(datagram);
    }


    /**
     * Returns the time elapsed since data was last received from this peer.
     *
     * @return The time elapsed in **seconds**.
     */
    @:allow(udprotean.server.UDProteanServer)
    @:noCompletion
    inline function getLastReceivedElapsed(): Float
    {
        return lastReceived.elapsed();
    }


    /**
     * Returns the time elapsed since data was last sent to this peer.
     *
     * @return The time elapsed in **seconds**.
     */
    @:noCompletion
    inline function getLastTransmittedElapsed(): Float
    {
        return lastTransmitted.elapsed();
    }


    @:allow(udprotean.server.UDProteanServer)
    @:noCompletion
    inline function resetLastReceivedTimestamp()
    {
        lastReceived = Timestamp.Now;
    }


    @:noCompletion
    inline function resetLastTransmittedTimestamp()
    {
        lastTransmitted = Timestamp.Now;
    }


    @:noCompletion @:protected
    override final function onTransmit(datagram: Bytes)
    {
        #if UDPROTEAN_UNIT_TEST
        if (rand.random() >= PacketLoss)
        #end

        resetLastTransmittedTimestamp();

        if (socket.isConnected())
        {
            socket.sendToPeer(datagram);
        }
        else
        {
            cast(socket, ServerUdpSocket).send(datagram, peerAddress);
        }
    }


    @:noCompletion @:protected
    final override function onMessageReceived(message: Bytes)
    {
        onMessage(message);
    }


    @:noCompletion @:allow(udprotean.server.UDProteanServer)
    final function onUnreliableMessageReceived(datagram: Bytes)
    {
        resetLastReceivedTimestamp();

        var commandCodeLength: Int = CommandCode.UnreliableMessage.getByteLength();
        var message = datagram.sub(commandCodeLength, datagram.length - commandCodeLength);
        onMessage(message);
    }


    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function initialize() { }
    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onConnect() { }
    @IgnoreCover                                           function onMessage(message: Bytes) { }
    @IgnoreCover @:allow(udprotean.server.UDProteanServer) function onDisconnect() { }
}
