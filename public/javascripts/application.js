YUI({
    modules: {
        biddingbox: {
            name: "Bridge Bidding Box",
            type: "js",
            path: "../bridge/biddingbox/biddingbox.js",
            requires: ["widget"]
        }
    }
}).use("biddingbox", function(Y) {
    biddingBox = new Y.BiddingBox();
    biddingBox.render();
    biddingBox.on("bid", function(event) {
        console.log(event[0] + " (" + event[1] + ")");
    });
});
