package udprotean.shared;


/**
 * Configures the base socket type which will be used by `UdpSocketEx`.
 *
 * This is to avoid using an intermediate interface for custom socket types
 * for targets like Lua.
 */
typedef BaseSocketType =

#if lua
    udprotean.shared.platform.lua.LuaUdpSocket
#else
    udprotean.shared.BaseSocketType.StdUdpSocket
#end

;

@:forward(setBlocking, sendTo, readFrom, bind, connect, close, peer)
abstract StdUdpSocket(sys.net.UdpSocket)
{
    public inline function new()
    {
        this = new sys.net.UdpSocket();
    }


    public inline function writeBytes(buf: haxe.io.Bytes, pos: Int, len: Int)
    {
        this.output.writeFullBytes(buf, pos, len);
    }


    public inline function readBytes(buf: haxe.io.Bytes, pos: Int, len: Int)
    {
        return this.input.readBytes(buf, pos, len);
    }
}
