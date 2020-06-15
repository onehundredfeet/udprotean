package udprotean.client;

import udprotean.shared.UdpSocketLayer;


/**
 * Only forwards peer methods that the client should use.
 */
@:forward(
    readFromPeer,
    readFromPeerTimeout,
    trySendToPeerAndRead,
    sendToPeer,
    connect,
    close,
    isConnected,
    recvFromAddressId,
    setBlocking
)
abstract ClientUdpSocket(UdpSocketLayer)
{
    public inline function new()
    {
        this = new UdpSocketLayer();
    }
}
