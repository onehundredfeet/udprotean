import utest.Runner;
import utest.ui.Report;

class TestMain
{
    static function main()
    {
        var runner = new Runner();
        runner.addCase(new TestDatagramBuffer());
        runner.addCase(new TestSequence());
        runner.addCase(new TestSequentialCommunication());
        runner.addCase(new TestSocket());

        Report.create(runner);

        runner.run();
    }
}

