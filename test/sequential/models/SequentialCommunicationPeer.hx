package sequential.models;

import haxe.io.Bytes;
import seedyrng.Random;
import udprotean.shared.protocol.SequentialCommunication;


class SequentialCommunicationPeer extends SequentialCommunication
{
    var other: SequentialCommunication;
    var callback: Bytes->Void;

    var rand: Random;
    var packetLoss: Float = 0;


    public function new(callback: Bytes->Void, seed: Null<Int> = null)
    {
        super();
        this.callback = callback;
        rand = new Random();
    }


    public function setOther(other: SequentialCommunication)
    {
        this.other = other;
    }


    public function setPacketLoss(packetLoss: Float)
    {
        this.packetLoss = packetLoss;
    }


    override function onTransmit(datagram: Bytes) 
    {
        if (rand.uniform(0, 1) >= packetLoss)
        {
            other.onReceived(datagram);
        }
    }


    override function onMessageReceived(datagram: Bytes) 
    {
        callback(datagram);
    }
}
