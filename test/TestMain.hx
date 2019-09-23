import haxe.unit.TestRunner;

class TestMain
{
    static function main()
    {
        var runner = new TestRunner();
        runner.add(new TestSequence());
        runner.add(new TestSocket());

        runner.run();
    }
}

