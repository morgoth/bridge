YUI(YUICONFIG).use("node", "table", "instantaction", "gallery-preload", function(Y) {
    if(Y.one("#table")) {
        var images = "cj,cq,ck,dj,dq,dk,hj,hq,hk,sj,sq,sk";
        new Y.Bridge.Table({ container: "#table", plugins: [{ fn: Y.Bridge.InstantAction }] });

        Y.each("cj,cq,ck,dj,dq,dk,hj,hq,hk,sj,sq,sk".split(","), function(card) {
            Y.preload("/images/cards/" + card + ".png");
        });
    }
});
