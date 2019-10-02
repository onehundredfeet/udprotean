package sequential;

import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;
import udprotean.shared.protocol.UDProteanConfiguration;


@:access(udprotean.shared.protocol.SequentialCommunication)
class TestSequentialCommunicationBase extends SequentialCommunication implements ITest
{
    final SequenceSize = UDProteanConfiguration.SequenceSize;
    final SequenceBytes = UDProteanConfiguration.SequenceBytes;
    final FragmentSize = UDProteanConfiguration.FragmentSize;

    var sendExpected: Int = 0;


    public function new()
    {
        super();
    }


    function teardown()
    {
        initSequentialCommunication();
        sendExpected = 0;
    }


    inline function b(hex: String): Bytes
    {
        return Bytes.ofHex(hex);
    }


    function dgramInt(seq: Int, frag: Int, data: Int)
    {
        var buffer: Bytes = Bytes.alloc(Std.int(SequenceBytes + 1 + 4));
        buffer.setInt32(0, seq);
        buffer.set(SequenceBytes, frag);
        buffer.setInt32(SequenceBytes + 1, data);
        return buffer;
    }
}
