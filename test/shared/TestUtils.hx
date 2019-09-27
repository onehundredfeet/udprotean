package shared;

import utest.ITest;
import haxe.io.Bytes;
import utest.Assert;
import udprotean.shared.Utils;
import udprotean.shared.Timestamp;


class TestUtils implements ITest
{
    public function new() { }


    function specTimestamp()
    {
        var ts: Timestamp = new Timestamp();
        var tnow: Float = ts;

        Sys.sleep(0.001);

        ts.elapsed() > 0;
        ts.elapsedMs() > 0;
        ts.elapsedMs() > ts.elapsed();

        ts.reset();

        tnow < cast(ts, Float);
    }


    function testHandshake()
    {
        for (_ in 0...1000)
        {
            var hs: String = Utils.generateHandshake();

            Assert.equals(0, hs.length % 2);            

            var hsbytes: Bytes = Bytes.ofHex(hs);

            Assert.isTrue(Utils.isHandshake(hsbytes));
        }
    }
}
