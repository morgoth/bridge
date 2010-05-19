YUI({
    filter: "raw",
    modules: {
        "gallery-io-poller": {
            path: "../yui3-gallery/gallery-io-poller/gallery-io-poller.js",
            requires: ["io-base", "base-base"]
        }
    }
}).use("test", "console", "node-event-simulate", "widget", "mustache", "gallery-io-poller", "chat", function(Y) {
    var ChatTestCase,
        isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;

    ChatTestCase = new Y.Test.Case({

        name: "Claim Preview Tests",

        setUp: function() {
            this.chat = new Y.Bridge.Chat({ channelId: 1, name: "user3@example.com" });
            this.chat.render();
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
