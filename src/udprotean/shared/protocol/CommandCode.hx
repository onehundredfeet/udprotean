package udprotean.shared.protocol;

import haxe.io.Bytes;


@:enum
abstract CommandCode(String) from String to String
{
    var Handshake  = "ffff";
    var Disconnect = "fffe";


    public static inline function ofBytes(bytes: Bytes): CommandCode
    {
        return bytes.length == 6 ? bytes.toHex().substr(0, 4) : "";
    }
}
