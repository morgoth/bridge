YUI({
    filter: "debug",
    modules: {
        mustache: {
            path: "../bridge/mustache/mustache.js"
        },
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
            requires: ["widget", "mustache"]
        },
        trick: {
            path: "../bridge/trick/trick.js",
            requires: ["widget"]
        },
        table: {
            path: "../bridge/table/table.js",
            requires: ["base-base", "node", "gallery-io-poller", "json", "mustache", "hand"]
        },
        "gallery-io-poller": {
            path: "../yui-gallery/gallery-io-poller/gallery-io-poller.js",
            requires: ["io-base", "base-base"]
        }
    }
}).use("table", function(Y) {
    new Y.Bridge.Table({ container: "#table" });
});
