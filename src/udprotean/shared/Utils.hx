package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;


class Utils
{
    /**
     * Returns the current UNIX timestamp in milliseconds.
     */
    public static inline function getTimestamp(): Float
    {
        #if (cpp || neko)
            return Sys.time() * 1000;
        #else
            return Date.now().getTime();
        #end
    }


    public static inline function generateHandshake(): String
    {
        return "ffff" + StringTools.hex(randomInt(), 8).toLowerCase();
    }


    public static inline function isHandshake(datagram: Bytes): Bool
    {
        return datagram.length == 6 && StringTools.startsWith(datagram.toHex(), "ffff");
    }

    
    public static inline function addressToString(addr: Address)
    {
        return addr.host + ":" + addr.port;
    }


    public static inline function randomInt(): Int
    {
        return (Std.random(0xff) << 24) |
            (Std.random(0xff) << 16) |
            (Std.random(0xff) << 8) |
            Std.random(0xff);
    }
}
