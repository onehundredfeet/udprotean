import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


class TestDatagramBuffer extends Test
{
    static inline final BufferSize = 512;


    function testEmpty()
    {
        var buffer: DatagramBuffer = new DatagramBuffer(BufferSize);

        for (i in 0...BufferSize)
        {
            Assert.isTrue( buffer.isEmpty(i) );
            Assert.isFalse( buffer.isStale(i) );
        }

        buffer.insert(12, Bytes.alloc(24));
        buffer.clear(12);
        Assert.isTrue( buffer.isEmpty(12) );
        Assert.isFalse( buffer.isStale(12) );
    }


    function testTimestamps()
    {
        var buffer: DatagramBuffer = new DatagramBuffer(BufferSize);
        buffer.insert(12, Bytes.alloc(24));

        Assert.isFalse( buffer.isStale(12) );

        Sys.sleep(0.002 + SequentialCommunication.StaleDatagramAge / 1000);

        Assert.isTrue( buffer.isStale(12) );

        buffer.refresh(12);

        Assert.isFalse( buffer.isStale(12) );
    }
}
