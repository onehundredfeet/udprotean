package udprotean.shared;

import haxe.io.Bytes;
import sys.net.Address;
import sys.net.Host;


interface SocketBase
{
    function setBlocking(blocking: Bool): Void;

    function sendTo(buf: Bytes, pos: Int, len: Int, addr: Address): Int;

    function readFrom(buf: Bytes, pos: Int, len: Int, addr: Address): Int;

    function bind(host: Host, port: Int): Void;

    function connect(host: Host, port: Int): Void;

    function close(): Void;

    function peer(): {host:Host, port:Int};
}
