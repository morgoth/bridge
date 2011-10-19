YUI().use("test", "console", "helpers-test", "bid-model-list-test", "bid-model-test", "board-model-test", function (Y) {
    window.Y = Y;

    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(Y.Bridge.Test.Helpers);
    Y.Test.Runner.add(Y.Bridge.Test.Model.BidList);
    Y.Test.Runner.add(Y.Bridge.Test.Model.Bid);
    Y.Test.Runner.add(Y.Bridge.Test.Model.Board);

    Y.Test.Runner.run();
});
