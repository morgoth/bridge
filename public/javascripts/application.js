YUI(YUICONFIG).use("cssreset", "cssbase", "cssfonts", "cssgrids", "node", "table", "instantaction", "gallery-preload", function(Y) {
    if(Y.one("#table")) {
        new Y.Bridge.Table({ contentBox: "#table", plugins: [{ fn: Y.Bridge.InstantAction }] }).render();

        Y.each("cj,cq,ck,dj,dq,dk,hj,hq,hk,sj,sq,sk".split(","), function(card) {
            Y.preload("/images/cards/" + card + ".png");
        });
    }
});
