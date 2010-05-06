YUI({ filter: "raw" }).use("test", "console", "node-event-simulate", "widget", "mustache", "claim", function(Y) {
    var ClaimTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    ClaimTestCase = new Y.Test.Case({

        name: "Bidding Box Tests",

        setUp: function() {
            this.claim = new Y.Bridge.Claim();
            this.claim.render();
        },

        tearDown: function() {
            // this.claim.destroy();
            // delete this.claim;
        },

        testFirst: function() {
            this.claim.on("claim", function(event) {
                Y.log("claim");
                Y.log(event[0]);
                Y.log(event[1]);
            });

            this.claim.on("cancel", function(event) {
                Y.log("cancel");
            });
        }

    });

    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(ClaimTestCase);
    Y.Test.Runner.run();
});
