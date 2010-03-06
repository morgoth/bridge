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
        },
        hand: {
            name: "Bridge Hand",
            type: "js",
            path: "../bridge/hand/hand.js",
            requires: ["widget"]
        },
        trick: {
            name: "Bridge Trick",
            type: "js",
            path: "../bridge/trick/trick.js",
            requires: ["widget"]
        }
    }
}).use("biddingbox", "auction", "hand", "trick", function(Y) {
    auction = new Y.Auction();
    auction.render();
    auction.on("bid", function(event) {
        var position = event[0];
        // console.log(position);
    });

    biddingBox = new Y.BiddingBox();
    biddingBox.render();
    biddingBox.on("bid", function(event) {
        var bid = event[0],
            alert = event[1];
        // console.log(bid + " (" + alert + ")");
        biddingBox.reset();
        biddingBox.set("contract", bid);
        auction.addBid(bid);
    });

    hand = new Y.Hand();
    hand.render();
    hand.on("card", function(event) {
        var card = event[0];
        console.log(card);
    });

    trick = new Y.Trick();
    trick.render();
});
