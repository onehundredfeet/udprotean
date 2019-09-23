import haxe.unit.TestRunner;

class TestMain
{
    static function main()
    {
        var runner = new TestRunner();
        runner.add(new TestSocket());

        runner.run();
    }
}

