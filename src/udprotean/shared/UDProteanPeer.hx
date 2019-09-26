package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;
import udprotean.shared.protocol.SequentialCommunication;


class UDProteanPeer extends SequentialCommunication
{
    var socket: UdpSocketEx;
    var peerAddress: Address;


    public function new(socket: UdpSocketEx, peerAddress: Address)
    {
        super();
        this.socket = socket;
        this.peerAddress = peerAddress;
    }


    override final function onTransmit(message: Bytes) 
    {
        socket.sendTo(message, peerAddress);
    }

    
    override function onMessageReceived(message: Bytes) 
    {
        super.onMessageReceived(message);
    }
}
