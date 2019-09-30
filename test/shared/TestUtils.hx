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


    function testHandshakeDisconnect()
    {
        for (_ in 0...1000)
        {
            var hs: String = Utils.generateHandshake();
            var dc: String = Utils.getDisconnectCode(hs);

            Assert.equals(0, hs.length % 2);
            Assert.equals(0, dc.length % 2);

            var hsbytes: Bytes = Bytes.ofHex(hs);
            var dcbytes: Bytes = Bytes.ofHex(dc);

            Assert.isTrue(Utils.isHandshake(hsbytes));
            Assert.isTrue(Utils.isDisconnect(dcbytes));
        }
    }


    function testPeerID()
    {
        for (_ in 0...1000)
        {
            var hs: String = Utils.generateHandshake();
            var dc: String = Utils.getDisconnectCode(hs);

            var hsPeerID: String = Utils.generatePeerID(hs, "127.0.0.1:9001");
            var dcPeerID: String = Utils.generatePeerID(dc, "127.0.0.1:9001");

            Assert.equals(hsPeerID, dcPeerID);
        }
    }
}
