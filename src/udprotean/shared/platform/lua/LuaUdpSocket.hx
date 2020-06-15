package udprotean.shared.platform.lua;

#if lua
import udprotean.shared.platform.lua.NativeSocket.UdpPeer;
import haxe.io.Bytes;
import haxe.io.Output;
import sys.net.Address;
import sys.net.Host;


abstract LuaUdpSocket(NativeSocket)
{
	public inline function new()
    {
        this = NativeSocket.udp();
	}


    public inline function setBlocking(blocking: Bool): Void
    {
        if (blocking)
        {
            this.settimeout(0);
        }
        else
        {
            this.settimeout(1e-3);
        }
    }


    public inline function writeBytes(buf: Bytes, pos: Int, len: Int): Int
    {
        return this.send(buf.toString());
    }


    public inline function sendTo(buf: Bytes, pos: Int, len: Int, addr: Address): Int
    {
        return this.sendto(buf.toString(), addr.getHost().toString(), addr.port);
    }


    public inline function readFrom(buf: Bytes, pos: Int, len: Int, addr: Address): Int
    {
        var res = this.receivefrom();

        var data: Bytes = Bytes.ofString(res.data);

        buf.blit(pos, data, 0, data.length);

        addr.host = Utils.ipToNum(res.ip);
        addr.port = res.port;

        return data.length;
    }


    public inline function bind(host: Host, port: Int): Void
    {
        NativeSocket.bind(host.toString(), port);
    }


    public inline function connect(host: Host, port: Int): Void
    {
        this.setpeername(host.host, port);
    }


    public inline function close(): Void
    {
        this.setpeername('*');
    }


    public inline function peer(): {host: Host, port: Int}
    {
        var peer: UdpPeer = this.getpeername();

        return {
            host: new Host(peer.ip),
            port: peer.port
        };
    }
}
#end
