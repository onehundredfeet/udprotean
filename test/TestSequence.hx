import haxe.unit.TestCase;

import udprotean.shared.protocol.Sequence;
import udprotean.shared.protocol.SequentialCommunication;


class TestSequence extends TestCase
{
    function testPreviousAndNext()
    {
        var sequence = new Sequence();

        assertEquals(SequentialCommunication.SequenceSize - 1, Sequence.maxValue);

        sequence.set(0);
        assertEquals(1, sequence.next);
        assertEquals(Sequence.maxValue, sequence.previous);

        sequence.set(128);
        assertEquals(129, sequence.next);
        assertEquals(127, sequence.previous);

        
        sequence.set(Sequence.maxValue);
        assertEquals(0, sequence.next);
        assertEquals(Sequence.maxValue - 1, sequence.previous);
    }

    function testSequenceMove()
    {
        var sequence = new Sequence();

        for (i in 0...Sequence.maxValue)
        {
            assertEquals(i, sequence);
            sequence.moveNext();
        }

        sequence.set(0);
        for (i in 0...Sequence.maxValue)
        {
            assertEquals(0, sequence);
            sequence.movePrevious();
            sequence.moveNext();
        }

        sequence.set(Sequence.maxValue);
        for (i in 0...Sequence.maxValue)
        {
            sequence.movePrevious();
        }
        assertEquals(0, sequence);
    }
}
