YUI().use("test", "console", "helpers-test", function (Y) {
    new Y.Console({ newestOnTop: false, width: 500, height: 500 }).render();

    Y.Test.Runner.add(Y.Bridge.Test.Helpers);

    Y.Test.Runner.run();
});
