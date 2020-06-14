package udprotean.shared.platform.lua;

#if lua
@:luaRequire("socket")
extern class NativeSocket
{
    static function bind(address: String, port: Int): Void;


    static function udp(): NativeSocket;


    function sendto(datagram: String, ip: String, port: Int): Int;


    function receivefrom(size: Int = 0): ReceiveFromResult;


    function getpeername(): UdpPeer;


    function settimeout(value: Float): Void;
}


@:multiReturn
extern class ReceiveFromResult
{
    var data: String;
    var ip: String;
    var port: Int;
}


@:multiReturn
extern class UdpPeer
{
    var ip: String;

    var port: Int;
}
#end

