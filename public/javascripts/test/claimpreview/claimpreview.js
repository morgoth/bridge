YUI({ filter: "raw" }).use("test", "console", "node-event-simulate", "widget", "mustache", "claimpreview", function(Y) {
    var ClaimPreviewTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    ClaimPreviewTestCase = new Y.Test.Case({

        name: "Claim Preview Tests",

        setUp: function() {
            this.claimPreview = new Y.Bridge.ClaimPreview();
            this.claimPreview.render();
            this.claimPreview.set("acceptEnabled", false);
            this.claimPreview.set("rejectEnabled", false);
        },

        tearDown: function() {
            // this.claimPreview.destroy();
            // delete this.claimPreview;
        },

        testTest: function() {

            // this.wait();
        }

    });

    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(ClaimPreviewTestCase);
    Y.Test.Runner.run();
});
