package udprotean.shared.platform.lua;

#if lua
@:luaRequire("socket")
extern class NativeSocket
{
    static function udp(): NativeSocket;


    function setsockname(address: String, port: Int): Void;


    function send(datagram: String): Int;


    function sendto(datagram: String, ip: String, port: Int): Int;


    function receive(size: Int = 0): String;


    function receivefrom(size: Int = 0): ReceiveFromResult;


    function getpeername(): UdpPeer;


    @:overload(function(address: String): Void {})
    function setpeername(address: String, port: Int): Void;


    function settimeout(value: Float): Void;


    function close(): Void;
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

