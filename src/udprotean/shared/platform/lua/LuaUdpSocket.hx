package udprotean.shared.platform.lua;

#if lua
import udprotean.shared.platform.lua.NativeSocket.UdpPeer;
import haxe.io.Bytes;
import sys.net.Address;
import sys.net.Host;


class LuaUdpSocket implements SocketBase
{
    var sock: NativeSocket;


	public function new()
    {
        sock = NativeSocket.udp();
	}

    public function setBlocking(blocking: Bool): Void
    {
        if (blocking)
        {
            sock.settimeout(0);
        }
        else
        {
            sock.settimeout(1e-3);
        }
    }


    public function sendTo(buf: Bytes, pos: Int, len: Int, addr: Address): Int
    {
        return sock.sendto(buf.toString(), addr.getHost().toString(), addr.port);
    }


    public function readFrom(buf: Bytes, pos: Int, len: Int, addr: Address): Int
    {
        var res = sock.receivefrom();

        var data: Bytes = Bytes.ofString(res.data);

        buf.blit(pos, data, 0, data.length);

        addr.host = Utils.ipToNum(res.ip);
        addr.port = res.port;

        return data.length;
    }


    public function bind(host: Host, port: Int): Void
    {
        NativeSocket.bind(host.toString(), port);
    }


    public function connect(host: Host, port: Int): Void
    {

    }


    public function close(): Void
    {

    }


    public function peer(): {host: Host, port: Int}
    {
        var peer: UdpPeer = sock.getpeername();

        return {
            host: new Host(peer.ip),
            port: peer.port
        };
    }
}
#end
