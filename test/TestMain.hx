import utest.Runner;
import utest.ui.Report;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode;
import mcover.coverage.MCoverage;

import sequential.*;


class TestMain
{
    static function main()
    {
        var runner = new Runner();
        runner.onComplete.add(onComplete);
        
        runner.addCases("sequential", false);
        runner.addCase(new TestDatagramBuffer());
        runner.addCase(new TestSequence());
        runner.addCase(new TestSocket());

        Report.create(runner, SuccessResultsDisplayMode.NeverShowSuccessResults, HeaderDisplayMode.AlwaysShowHeader);

        runner.run();
    }


    static function onComplete(runner: Runner)
    {
        var covLogger = MCoverage.getLogger();
        covLogger.report();
    }
}

