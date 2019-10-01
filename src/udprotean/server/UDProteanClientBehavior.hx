package udprotean.server;

import sys.net.Address;
import haxe.crypto.Sha1;
import udprotean.shared.UdpSocketEx;
import udprotean.shared.UDProteanPeer;
import haxe.io.Bytes;

using udprotean.shared.Utils;


class UDProteanClientBehavior extends UDProteanPeer
{
    @:noCompletion
    public final peerID: String;


    @:protected
    public final function new(socket: UdpSocketEx, peerAddress: Address, peerID: String)
    {
        this.peerID = peerID;
        super(socket, peerAddress);
    }
    
    
    public final override function update()
    {
        super.update();
    }
}
