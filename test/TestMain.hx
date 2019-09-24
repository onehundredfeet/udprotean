import utest.Runner;
import utest.ui.Report;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode;

import sequential.*;


class TestMain
{
    static function main()
    {
        var runner = new Runner();
        runner.addCase(new TestDatagramBuffer());
        runner.addCase(new TestSequence());
        runner.addCase(new TestSequentialCommunicationBase());
        runner.addCase(new TestSequentialCommunicationSend());
        runner.addCase(new TestSequentialCommunicationSendFragment());
        runner.addCase(new TestSocket());

        Report.create(runner, SuccessResultsDisplayMode.NeverShowSuccessResults, HeaderDisplayMode.AlwaysShowHeader);

        runner.run();
    }
}

