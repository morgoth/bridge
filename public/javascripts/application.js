rYUI(YUICONFIG).use("node", "table", "instantaction", function(Y) {
    if(Y.one("#table")) {
        new Y.Bridge.Table({ container: "#table", plugins: [{ fn: Y.Bridge.InstantAction }] });
    }
});
