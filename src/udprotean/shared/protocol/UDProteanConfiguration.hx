package udprotean.shared.protocol;


import haxe.macro.Context;

class UDProteanConfiguration
{
    #if !macro
    /**
     * The size of the sequential communication cyclic buffers.
     * Increasing this number makes the protocol more resistant to
     * packet loss and big transmission rates, but increases the memory footprint
     * as more datagrams will be getting stored.
     *
     * **This option needs to have the same value on both peers.**
     */
    public static inline var SequenceSize                 = getOrDefault("UDPROTEAN_SEQUENCE_SIZE", 512);


    /**
     * The maximum transmittable datagram size in bytes.
     * Fragment numbers are represented with one byte, so the maximum
     * size of a single message which can be sent by the protocol will be `255 * FragmentSize`.
     *
     * Changing this to a value higher than a normal network MTU can cause problems.
     *
     * **This option needs to have the same value on both peers.**
     */
    public static inline var FragmentSize                 = getOrDefault("UDPROTEAN_FRAGMENT_SIZE", 540);


    /**
     * The time (in ms) after which a not acknowledged datagram should be re-sent.
     * A larger value is recommended for servers with multiple clients.
     */
    public static inline var RepeatDatagramAge            = getOrDefault("UDPROTEAN_REPEAT_AGE", 50);


    /**
     * The time (in ms) after which retransmission of a datagram should be requested when receiving one out-of-order.
     * A larger value is recommended for servers with multiple clients.
     */
    public static inline var StaleDatagramAge             = getOrDefault("UDPROTEAN_STALE_AGE", 20);


    /**
     * The number of bytes needed to hold the sequence number.
     * The amount of bytes set here needs to be able to hold the maximum sequence number
     * which is `SequenceSize-1` as a **signed** integer.
     *
     * **This option needs to have the same value on both peers.**
     */
    public static inline var SequenceBytes                = getOrDefault("UDPROTEAN_SEQUENCE_BYTES", 3);


    /**
     * The maximum cyclical distance one datagram can have from another and be presumed to be earlier than it.
     * This is used as a threshold for discarding datagrams which arrive, and which are presumably older than
     * the ones that have already been processed. A value too small may caused older re-transmitted datagrams to be
     * processed a second time when the cyclic buffer reaches them on the next pass, and a value too big can cause
     * legitimate datagrams to be discarded during heavy network traffic and/or significant packet loss, when the
     * head of the cyclic buffer approaches its tail.
     */
    public static inline var SequenceDistanceRelationship = getOrDefault("UDPROTEAN_SEQUENCE_DISTANCE", 32);

    #end


    @IgnoreCover
    macro static function getOrDefault(key: String, defaultValue: Int)
    {
        if (Context.defined(key))
        {
            return macro $v{ Context.definedValue(key) };
        }
        else
        {
            return macro $v{ defaultValue };
        }
    }
}
