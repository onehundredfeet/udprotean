package udprotean.shared;


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
}
