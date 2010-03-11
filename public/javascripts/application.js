YUI({
    filter: "debug",
    modules: {
        biddingbox: {
            path: "../bridge/biddingbox/biddingbox.js",
            requires: ["widget"]
        },
        auction: {
            path: "../bridge/auction/auction.js",
            requires: ["widget"]
        },
        hand: {
            path: "../bridge/hand/hand.js",
            requires: ["widget"]
        },
        trick: {
            path: "../bridge/trick/trick.js",
            requires: ["widget"]
        },
        table: {
            path: "../bridge/table/table.js",
            requires: ["base-base", "node", "gallery-io-poller", "json", "substitute"]
        },
        "gallery-io-poller": {
            path: "../yui-gallery/gallery-io-poller/gallery-io-poller.js",
            requires: ["io-base", "base-base"]
        }
    }
}).use("table", function(Y) {
    new Y.Bridge.Table({ container: "#table" });
});
