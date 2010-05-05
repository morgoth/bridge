YUI().use("test", "console", "node-event-simulate", "widget", "mustache", "collection", "helpers", "biddingbox", function(Y) {
    var BiddingBoxTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    BiddingBoxTestCase = new Y.Test.Case({

        name: "Bidding Box Tests",

        setUp: function() {
            this.biddingBox = new Y.Bridge.BiddingBox();
            this.biddingBox.render();
        },

        tearDown: function() {
            this.biddingBox.destroy();
            delete this.biddingBox;
        },

        testPass: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("PASS", event[0]);
                });
            }, this);

            Y.one(".yui3-biddingbox-modifier-pass").simulate("click");

            this.wait();
        }

    });

    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(BiddingBoxTestCase);
    Y.Test.Runner.run();
});
