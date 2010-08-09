YUI(YUICONFIG).use("test", "console", "helpers-testcase", "biddingbox-testcase", "claim-testcase", "claimpreview-testcase", function(Y) {
    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(Y.Bridge.BiddingBoxTestCase);
    Y.Test.Runner.add(Y.Bridge.ClaimPreviewTestCase);
    Y.Test.Runner.add(Y.Bridge.ClaimTestCase);
    Y.Test.Runner.add(Y.Bridge.HelpersTestCase);

    Y.Test.Runner.run();
});
