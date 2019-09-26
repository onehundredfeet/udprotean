import utest.Test;
import utest.Assert;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.SequentialCommunication;


class TestSequence extends Test
{
    function testPreviousAndNext()
    {
        var sequence = new Sequence();

        Assert.equals(SequentialCommunication.SequenceSize - 1, Sequence.maxValue);

        sequence.set(0);
        Assert.equals(1, sequence.next);
        Assert.equals(Sequence.maxValue, sequence.previous);

        sequence.set(128);
        Assert.equals(129, sequence.next);
        Assert.equals(127, sequence.previous);

        
        sequence.set(Sequence.maxValue);
        Assert.equals(0, sequence.next);
        Assert.equals(Sequence.maxValue - 1, sequence.previous);
    }


    function testSequenceMove()
    {
        var sequence = new Sequence();

        for (i in 0...Sequence.maxValue)
        {
            Assert.equals(i, sequence);
            sequence.moveNext();
        }

        sequence.set(0);
        for (i in 0...Sequence.maxValue)
        {
            Assert.equals(0, sequence);
            sequence.movePrevious();
            sequence.moveNext();
        }

        sequence.set(Sequence.maxValue);
        for (i in 0...Sequence.maxValue)
        {
            sequence.movePrevious();
        }
        Assert.equals(0, sequence);
    }


    function testDistanceTo()
    {
        var s1 = new Sequence();
        var s2 = new Sequence();

        var cases = [
        //   s1 s2 d
            [0, 0, 0],
            [0, 1, 1],
            [1, 0, SequentialCommunication.SequenceSize - 1],
            [12, 24, 12],
            [25, 10, SequentialCommunication.SequenceSize - 15]
        ];

        for (c in cases)
        {
            s1 = c[0];
            s2 = c[1];

            Assert.equals(c[2], s1.distanceTo(s2));
        }
    }
}
