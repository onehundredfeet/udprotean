package sequential;

import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


@:access(udprotean.shared.protocol.SequentialCommunication)
class TestSequentialCommunicationSendFragment extends TestSequentialCommunicationBase implements ITest
{
    function testSend()
    {
        var buffer: Bytes = Bytes.alloc(FragmentSize * 4);
        Assert.isTrue(true);
    }


    override function onTransmit(datagram: Bytes) 
    {
    }
}
