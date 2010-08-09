YUI.add("claim-testcase", function(Y) {

    var ClaimTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    Y.namespace("Bridge");

    ClaimTestCase = new Y.Test.Case({

        name: "Claim Tests",

        setUp: function() {
            this.claim = new Y.Bridge.Claim();
            this.claim.render();
        },

        tearDown: function() {
            this.claim.destroy();
            delete this.claim;
        },

        testMaxTricksChangesTricks: function() {
            this.claim.on("claim", function(event) {
                this.resume(function() {
                    areSame(5, event[0]);
                });
            }, this);

            this.claim.set("maxTricks", 5);
            Y.one(".yui3-claim-buttons-claim").simulate("click");
            this.wait();
        },

        testCantDeclareMoreThanMaxTricks: function() {
            this.claim.on("claim", function(event) {
                this.resume(function() {
                    areSame(13, event[0]);
                });
            }, this);

            Y.one(".yui3-claim-more-button").simulate("click");
            Y.one(".yui3-claim-buttons-claim").simulate("click");
            this.wait();
        },

        testDeclareOneTrickLess: function() {
            this.claim.on("claim", function(event) {
                this.resume(function() {
                    areSame(12, event[0]);
                });
            }, this);

            Y.one(".yui3-claim-less-button").simulate("click");
            Y.one(".yui3-claim-buttons-claim").simulate("click");
            this.wait();
        },

        testCantDeclareLessThanZeroTricks: function() {
            this.claim.on("claim", function(event) {
                this.resume(function() {
                    areSame(0, event[0]);
                });
            }, this);

            for(var i = 0; i <= 20; i++) {
                Y.one(".yui3-claim-less-button").simulate("click");
            }

            Y.one(".yui3-claim-buttons-claim").simulate("click");
            this.wait();
        },

        testClaimHasExplanation: function() {
            this.claim.on("claim", function(event) {
                this.resume(function() {
                    areSame("explanation", event[1]);
                });
            }, this);

            Y.one(".yui3-claim-explanation-input").set("value", "explanation");
            Y.one(".yui3-claim-buttons-claim").simulate("click");
            this.wait();
        },

        testCancel: function() {
            this.claim.on("cancel", function(event) {
                this.resume();
            }, this);

            Y.one(".yui3-claim-buttons-cancel").simulate("click");
            this.wait();
        }
    });

    Y.Bridge.ClaimTestCase = ClaimTestCase;

}, "", { requires: ["test", "console", "node-event-simulate", "widget", "mustache", "claim"] });
