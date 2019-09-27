package udprotean.shared;

import sys.net.Address;
import haxe.io.Bytes;
import seedyrng.Seedy;


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
        return "FF" + StringTools.hex(Seedy.instance.nextInt(), 4);
    }


    public static inline function isHandshake(datagram: Bytes): Bool
    {
        return datagram.length == 6 && StringTools.startsWith(datagram.toHex(), "FF");
    }

    
    public static inline function addressToString(addr: Address)
    {
        return addr.host + ":" + addr.port;
    }
}
