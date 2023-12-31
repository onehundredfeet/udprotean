import utest.Runner;
import utest.ui.Report;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode;
import mcover.coverage.MCoverage;
import mcover.coverage.client.PrintClient;


class TestMain
{
    static function main()
    {
        var runner = new Runner();
        runner.onComplete.add(onComplete);

        #if !lua
        runner.addCases("clientserver", false);
        runner.addCases("sequential", false);
        #end
        runner.addCases("shared", false);

        Report.create(runner, SuccessResultsDisplayMode.NeverShowSuccessResults, HeaderDisplayMode.AlwaysShowHeader);

        runner.run();
    }


    static function onComplete(runner: Runner)
    {
        var covLogger = MCoverage.getLogger();
        covLogger.report();
    }
}

