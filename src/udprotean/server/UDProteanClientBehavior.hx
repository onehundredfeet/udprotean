package udprotean.server;

import sys.net.Address;
import udprotean.shared.UdpSocketEx;
import udprotean.shared.UDProteanPeer;
import haxe.io.Bytes;


class UDProteanClientBehavior extends UDProteanPeer
{
    public final function new(socket: UdpSocketEx, peerAddress: Address)
    {
        super(socket, peerAddress);
    }
}
