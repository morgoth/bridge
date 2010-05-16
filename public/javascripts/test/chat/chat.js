YUI({ filter: "raw" }).use("test", "console", "node-event-simulate", "widget", "mustache", "chat", function(Y) {
    var ChatTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    ChatTestCase = new Y.Test.Case({

        name: "Claim Preview Tests",

        setUp: function() {
            this.chat = new Y.Bridge.Chat();
            this.chat.render();
            this.chat.set("acceptEnabled", false);
            this.chat.set("rejectEnabled", false);
        },

        tearDown: function() {
            // this.chat.destroy();
            // delete this.chat;
        },

        testTest: function() {

            // this.wait();
        }

    });

    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(ChatTestCase);
    Y.Test.Runner.run();
});
