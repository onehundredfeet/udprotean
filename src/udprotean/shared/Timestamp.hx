package udprotean.shared;


abstract Timestamp(Float)
{
    public inline function new()
    {
        reset();
    }


    public inline function reset()
    {
        this = Utils.getTimestamp();
    }


    public inline function elapsed(): Float
    {
        return elapsedMs() / 1000;
    }


    public inline function elapsedMs(): Float
    {
        return Utils.getTimestamp() - this;
    }
}
