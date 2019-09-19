import utest.Runner;
import utest.ui.Report;

class TestMain
{
    static function main()
    {
        var runner = new Runner();
        runner.addCase(new TestCase1());

        Report.create(runner);

        runner.run();
    }
}

