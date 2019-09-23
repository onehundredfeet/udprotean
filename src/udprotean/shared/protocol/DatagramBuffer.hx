package udprotean.shared.protocol;

import haxe.io.Bytes;


class DatagramBuffer
{
    var buffer: Array<Bytes>;
    var timestamps: Array<Float>;


    public function new(length: Int)
    {
        buffer = new Array<Bytes>();
        buffer.resize(length);
        timestamps = new Array<Float>();
        timestamps.resize(length);
    }


    /**
        Returns the datagram at the given index in the buffer.
    **/
    public inline function get(index: Int): Bytes
    {
        return buffer[index];
    }


    /**
        Inserts a datagram at the specified index in the buffer.
    **/
    public inline function insert(index: Int, datagram: Bytes)
    {
        buffer[index] = datagram;
        refresh(index);
    }


    /**
        Refreshes the timestamp of the datagram at the given index in the buffer.
    **/
    public inline function refresh(index: Int)
    {
        timestamps[index] = getTimestamp();
    }


    /**
        Returns `true` if the given index in the buffer is empty (null).
    **/
    public inline function isEmpty(index: Int): Bool
    {
        return buffer[index] == null;
    }


    /**
     * Returns `true` if the datagram at the given index in the buffer is older than StaleDatagramAge.
     */
    public inline function isStale(index: Int): Bool
    {
        return (getTimestamp() - timestamps[index]) > SequentialCommunication.StaleDatagramAge;
    }


    /**
     * Clears the given index in the buffer, setting it to null.
     */
    public inline function clear(index: Int)
    {
        buffer[index] = null;
    }


    /**
     * Returns the current UNIX timestamp in milliseconds.
     */
    static inline function getTimestamp(): Float
    {
        #if (cpp || neko)
            return Sys.time() * 1000;
        #else
            return Date.now().getTime();
        #end
    }
}
