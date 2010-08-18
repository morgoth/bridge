YUI(YUICONFIG).use("node", "table", function(Y) {
    if(Y.one("#table")) {
        new Y.Bridge.Table({ container: "#table" });
    }
});
