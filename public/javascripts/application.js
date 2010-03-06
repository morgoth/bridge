YUI({
    modules: {
        biddingbox: {
            name: "Bridge Bidding Box",
            type: "js",
            path: "../bridge/biddingbox/biddingbox.js",
            requires: ["widget"]
        },
        auction: {
            name: "Bridge Auction",
            type: "js",
            path: "../bridge/auction/auction.js",
            requires: ["widget"]
        }
    }
}).use("biddingbox", "auction", function(Y) {
    auction = new Y.Auction();
    auction.render();
    auction.on("bid", function(event) {
        console.log(event[0]);
    });

    biddingBox = new Y.BiddingBox();
    biddingBox.render();
    biddingBox.on("bid", function(event) {
        var bid = event[0],
            alert = event[1];
        console.log(bid + " (" + alert + ")");
        biddingBox.reset();
        biddingBox.set("contract", bid);
        auction.addBid(bid);
    });
});
