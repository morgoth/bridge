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
        },
        "gallery-io-poller": {
            name: "YIU3 Gallery IO Poller",
            type: "js",
            path: "../yui-gallery/gallery-io-poller/gallery-io-poller.js",
            requires: ["io-base", "base-base"]
        }
    }
}).use("biddingbox", "auction", "hand", "trick", "gallery-io-poller", function(Y) {
    // auction = new Y.Auction();
    // auction.render();
    // auction.on("bid", function(event) {
    //     var position = event[0];
    //     // console.log(position);
    // });

    // biddingBox = new Y.BiddingBox();
    // biddingBox.render();
    // biddingBox.on("bid", function(event) {
    //     var bid = event[0],
    //         alert = event[1];
    //     // console.log(bid + " (" + alert + ")");
    //     biddingBox.reset();
    //     biddingBox.set("contract", bid);
    //     auction.addBid(bid);
    // });

    // trick = new Y.Trick();
    // trick.render();

    var each = Y.each,
        Hand = Y.Hand,
        hands = {},
        DIRECTIONS = ["N", "E", "S", "W"];

    poll = Y.io.poll(3000, "/ajax/tables/1.json", {
        on: {
            modified: function(id, o, args) {
                console.log(o.status);
                console.log(o.responseText);
            },
            failure: function(id, o, args) {
                console.log(o.status);
            }
        }
    });

    poll.start();

    // myDataSource.sendRequest();

    // function renderHands() {
    //     each(DIRECTIONS, function(direction) {
    //         var hand = new Hand({ direction: direction });

    //         hands[direction] = hand;
    //         hand.render();
    //     });
    // }

    // function bindHands() {
    //     each(hands, function(hand) {

    //     });
    // }

    // renderHands();
});
