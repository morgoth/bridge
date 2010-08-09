YUI.add("claimpreview-testcase", function(Y) {

    var ClaimPreviewTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    Y.namespace("Bridge");

    ClaimPreviewTestCase = new Y.Test.Case({

        name: "Claim Preview Tests",

        setUp: function() {
            this.claimPreview = new Y.Bridge.ClaimPreview();
            this.claimPreview.render();
            this.claimPreview.setAttrs({
                claimId: 6,
                tricks: 13,
                totalTricks: 13,
                acceptEnabled: false,
                rejectEnabled: false,
                cancelEnabled: false,
                explanation: "my-explanation"
            });
        },

        tearDown: function() {
            this.claimPreview.destroy();
            delete this.claimPreview;
        },

        testCanAcceptClaimWhenAcceptIsEnabled: function() {
            this.claimPreview.on("accept", function(event) {
                this.resume(function() {
                    areSame(6, event[0]);
                });
            }, this);

            this.claimPreview.set("acceptEnabled", true);

            Y.one(".yui3-claimpreview-accept").simulate("click");

            this.wait();
        },

        testCanRejectClaimWhenRejectIsEnabled: function() {
            this.claimPreview.on("reject", function(event) {
                this.resume(function() {
                    areSame(6, event[0]);
                });
            }, this);

            this.claimPreview.set("rejectEnabled", true);

            Y.one(".yui3-claimpreview-reject").simulate("click");

            this.wait();
        },

        testCanCancelClaimWhenCancelIsEnabled: function() {
            this.claimPreview.on("reject", function(event) {
                this.resume(function() {
                    areSame(6, event[0]);
                });
            }, this);

            this.claimPreview.set("cancelEnabled", true);

            Y.one(".yui3-claimpreview-cancel").simulate("click");

            this.wait();
        },

        testDisplaysTricks: function() {
            this.claimPreview.set("tricks", 7);

            areSame("I claim 7 more tricks.", Y.one(".yui3-claimpreview-tricks").get("text"));
        },

        testDisplayExplanation: function() {
            this.claimPreview.set("explanation", "Because!");

            areSame("Because!", Y.one(".yui3-claimpreview-explanation").get("text"));
        }

    });

    Y.Bridge.ClaimPreviewTestCase = ClaimPreviewTestCase;

}, "", { requires: ["test", "console", "node-event-simulate", "widget", "mustache", "claimpreview"] });
