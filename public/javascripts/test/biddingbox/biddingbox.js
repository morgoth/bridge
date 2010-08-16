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
        },

        testLevelIsStored: function() {
            Y.one(".yui3-biddingbox-level-1").simulate("click");
            areSame("1", this.biddingBox.get("level"));

            Y.one(".yui3-biddingbox-level-3").simulate("click");
            areSame("3", this.biddingBox.get("level"));

            Y.one(".yui3-biddingbox-level-7").simulate("click");
            areSame("7", this.biddingBox.get("level"));
        },

        test1C: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("1C", event[0]);
                });
            }, this);

            Y.one(".yui3-biddingbox-level-1").simulate("click");
            Y.one(".yui3-biddingbox-suit-c").simulate("click");

            this.wait();
        },

        test7NT: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("7NT", event[0]);
                });
            }, this);

            Y.one(".yui3-biddingbox-level-7").simulate("click");
            Y.one(".yui3-biddingbox-suit-nt").simulate("click");

            this.wait();
        },

        testCantBid4HWhen4NTHasBeenGiven: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("5H", event[0]);
                });
            }, this);

            this.biddingBox.set("contract", "4NT");

            Y.one(".yui3-biddingbox-level-4").simulate("click");
            Y.one(".yui3-biddingbox-suit-h").simulate("click");

            Y.one(".yui3-biddingbox-level-5").simulate("click");
            Y.one(".yui3-biddingbox-suit-h").simulate("click");

            this.wait();
        },

        testCanBid4DWhen4CHasBeenGiven: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("4D", event[0]);
                });
            }, this);

            this.biddingBox.set("contract", "4C");

            Y.one(".yui3-biddingbox-level-4").simulate("click");
            Y.one(".yui3-biddingbox-suit-d").simulate("click");

            this.wait();
        },

        testLevelIsUndefinedAfterContractIsSet: function() {
            this.biddingBox.set("level", 5);

            this.biddingBox.set("contract", "3NT");

            isUndefined(this.biddingBox.get("level"));
        },

        testCanDoubleWhenDoubleIsEnabled: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("X", event[0]);
                });
            }, this);

            this.biddingBox.set("doubleEnabled", true);

            Y.one(".yui3-biddingbox-modifier-x").simulate("click");

            this.wait();
        },

        testCanRedoubleWhenRedoubleIsEnabled: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("XX", event[0]);
                });
            }, this);

            this.biddingBox.set("redoubleEnabled", true);

            Y.one(".yui3-biddingbox-modifier-xx").simulate("click");

            this.wait();
        },

        testCantDoubleWhenRedoubleIsEnabled: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("XX", event[0]);
                });
            }, this);

            this.biddingBox.set("doubleEnabled", true);
            this.biddingBox.set("redoubleEnabled", true);

            Y.one(".yui3-biddingbox-modifier-x").simulate("click");
            Y.one(".yui3-biddingbox-modifier-xx").simulate("click");

            this.wait();
        },

        testCantRedoubleWhenDoubleIsEnabled: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("X", event[0]);
                });
            }, this);

            this.biddingBox.set("redoubleEnabled", true);
            this.biddingBox.set("doubleEnabled", true);

            Y.one(".yui3-biddingbox-modifier-xx").simulate("click");
            Y.one(".yui3-biddingbox-modifier-x").simulate("click");

            this.wait();
        },

        testAlertIsPassedInTheEvent: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("PASS", event[0]);
                    areSame("trapping pass", event[1]);
                });
            }, this);

            Y.one(".yui3-biddingbox-alert").set("value", "trapping pass");
            Y.one(".yui3-biddingbox-modifier-pass").simulate("click");

            this.wait();
        },

        testAlertResetsAfterBid: function() {
            this.biddingBox.on("bid", function(event) {
                this.resume(function() {
                    areSame("", Y.one(".yui3-biddingbox-alert").get("value"));
                });
            }, this);

            Y.one(".yui3-biddingbox-alert").set("value", "trapping pass");
            Y.one(".yui3-biddingbox-modifier-pass").simulate("click");
        }

    });

    Y.Bridge.BiddingBoxTestCase = BiddingBoxTestCase;

}, "", { requires: ["test", "console", "node-event-simulate", "widget", "mustache", "collection", "helpers", "biddingbox"] });
