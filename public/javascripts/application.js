// prefetch following images (quick fix)
new Image().src = "/images/cards/deck.png";
new Image().src = "/images/cards/lost.png";
new Image().src = "/images/cards/won.png";

YUI(YUICONFIG).use("node", "table", "instantaction", function(Y) {
    if(Y.one("#table")) {
        new Y.Bridge.Table({ container: "#table", plugins: [{ fn: Y.Bridge.InstantAction }] });
    }
});
