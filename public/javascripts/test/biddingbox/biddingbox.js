YUI.add("biddingbox-testcase", function(Y) {

    var BiddingBoxTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    Y.namespace("Bridge");

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

    Y.Bridge.BiddingBoxTestCase = BiddingBoxTestCase;

}, "", { requires: ["test", "console", "node-event-simulate", "widget", "mustache", "collection", "helpers", "biddingbox"] });
