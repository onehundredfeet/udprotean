import haxe.unit.TestRunner;

class TestMain
{
    static function main()
    {
        var runner = new TestRunner();
        runner.add(new TestDatagramBuffer());
        runner.add(new TestSequence());
        runner.add(new TestSequentialCommunication());
        runner.add(new TestSocket());

        runner.run();
    }
}

