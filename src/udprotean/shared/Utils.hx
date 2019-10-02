package udprotean.shared;

import haxe.crypto.Sha1;
import sys.net.Address;
import haxe.io.Bytes;
import udprotean.shared.protocol.CommandCode;


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


    /**
     * Generates a random 6-byte handshake code.
     */
    public static inline function generateHandshake(): String
    {
        return CommandCode.Handshake + StringTools.hex(randomInt(), 8).toLowerCase();
    }


    /**
     * Generates a disconnect code for a given handshake code.
     */
    public static inline function getDisconnectCode(handshakeCode: String)
    {
        return CommandCode.Disconnect + handshakeCode.substr(4);
    }


    /**
     * Returns `true` if the given datagram is a handshake command.
     */
    public static inline function isHandshake(datagram: Bytes): Bool
    {
        return datagram.length == 6 && StringTools.startsWith(datagram.toHex(), CommandCode.Handshake);
    }


    /**
     * Returns `true` if the given datagram is a disconnect command.
     */
    public static inline function isDisconnect(datagram: Bytes): Bool
    {
        return datagram.length == 6 && StringTools.startsWith(datagram.toHex(), CommandCode.Disconnect);
    }


    /**
     * Calculates the Peer ID, given a code and a string representation of the peer's address.
     */
    public static inline function generatePeerID(code: String, addressString: String): String
    {
        return Sha1.encode(addressString + "|" + code.substr(4));
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
