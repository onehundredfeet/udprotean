package sequential;

import haxe.io.BytesData;
import utest.ITest;
import haxe.io.Bytes;
import utest.Test;
import utest.Assert;
import seedyrng.Random;
import seedyrng.Seedy;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.DatagramBuffer;
import udprotean.shared.protocol.SequentialCommunication;


@:access(udprotean.shared.protocol.SequentialCommunication)
class TestSequentialCommunicationSendFragment extends TestSequentialCommunicationBase implements ITest
{
    var seed: Int;
    var randSend: Random;
    var randTransmit: Random;
    var bufferSize: Int;

    var expectedFragment: Int;


    function setupClass()
    {
        seed = Seedy.randomInt(-999999, 999999);
    }


    function setup()
    {
        bufferSize = Seedy.randomInt(FragmentSize * 3, FragmentSize * 12);
        expectedFragment = Std.int(bufferSize / FragmentSize);

        randSend = new Random(seed);
        randTransmit = new Random(seed);
    }


    function testSendFragment()
    {
        var buffer: Bytes = Bytes.alloc(bufferSize);
        
        var index = 0;
        while (index < (buffer.length - 3))
        {
            buffer.setInt32(index, randSend.nextInt());
            index += 4;
        }

        send(buffer);
        Assert.equals(-1, expectedFragment);
    }


    override function onTransmit(message: Bytes) 
    {
        var sequenceNumber = Sequence.fromBytes(message);
        var data = message.sub(SequenceBytes, message.length - SequenceBytes);
        var fragmentNum = data.get(0);
        var payload = data.sub(1, data.length - 1);
        
        Assert.equals(expectedFragment, fragmentNum);
        Assert.equals(sendExpected % SequenceSize, sequenceNumber);
        sendExpected++;
        expectedFragment--;

        var index = 0;
        while (index < (payload.length - 3))
        {
            var num = payload.getInt32(index);

            Assert.equals(randTransmit.nextInt(), num);

            index += 4;
        }
    }
}
