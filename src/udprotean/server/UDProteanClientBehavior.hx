package udprotean.server;

import sys.net.Address;
import udprotean.client.ClientUdpSocket;
import udprotean.shared.UDProteanPeer;

using udprotean.shared.Utils;


class UDProteanClientBehavior extends UDProteanPeer
{
    @:noCompletion
    public final peerID: String;


    @:protected
    public final function new(socket: ClientUdpSocket, peerAddress: Address, peerID: String)
    {
        this.peerID = peerID;
        super(socket, peerAddress);
    }


    public final override function update()
    {
        super.update();
    }
}
