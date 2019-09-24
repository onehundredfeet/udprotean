import haxe.io.Bytes;
import haxe.unit.TestCase;

import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


class TestDatagramBuffer extends TestCase
{
    static inline final BufferSize = 512;


    function testEmpty()
    {
        var buffer: DatagramBuffer = new DatagramBuffer(BufferSize);

        for (i in 0...BufferSize)
        {
            assertTrue( buffer.isEmpty(i) );
            assertFalse( buffer.isStale(i) );
        }

        buffer.insert(12, Bytes.alloc(24));
        buffer.clear(12);
        assertTrue( buffer.isEmpty(12) );
        assertFalse( buffer.isStale(12) );
    }


    function testTimestamps()
    {
        var buffer: DatagramBuffer = new DatagramBuffer(BufferSize);
        buffer.insert(12, Bytes.alloc(24));

        assertFalse( buffer.isStale(12) );

        Sys.sleep(0.002 + SequentialCommunication.StaleDatagramAge / 1000);

        assertTrue( buffer.isStale(12) );

        buffer.refresh(12);

        assertFalse( buffer.isStale(12) );
    }
}
