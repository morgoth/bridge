YUI().use("test", "console", "widget", "mustache", "collection", "helpers", "biddingbox", function(Y) {
    var BiddingBoxTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    BiddingBoxTestCase = new Y.Test.Case({

        name: "Bidding Box Tests",

        testRender: function() {
            new Y.Bridge.BiddingBox().render();
        }

    });

    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(BiddingBoxTestCase);
    Y.Test.Runner.run();
});
