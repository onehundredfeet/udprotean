package udprotean.server;

import udprotean.shared.UdpSocketLayer;


/**
 * Only forward non-peer methods that the server can use.
 */
@:forward(
    read,
    readTimeout,
    send,
    trySendAndRead,
    listen,
    setBlocking,
    close,
    recvFromAddress,
    recvFromAddressId,
    isConnected
)
abstract ServerUdpSocket(UdpSocketLayer)
{
    public inline function new()
    {
        this = new UdpSocketLayer();
    }
}
