WebSocket.__swfLocation = "/flash/WebSocketMain.swf";

YUI({
    filter: "raw",
    modules: {
        mustache: {
            path: "../bridge/mustache/mustache.js"
        },
        helpers: {
            path: "../bridge/helpers/helpers.js",
            requires: ["collection", "oop"]
        },
        biddingbox: {
            path: "../bridge/biddingbox/biddingbox.js",
            requires: ["widget", "mustache", "collection", "helpers"]
        },
        claim: {
            path: "../bridge/claim/claim.js",
            requires: ["widget", "mustache"]
        },
        claimpreview: {
            path: "../bridge/claimpreview/claimpreview.js",
            requires: ["widget", "mustache"]
        },
        info: {
            path: "../bridge/info/info.js",
            requires: ["widget", "mustache", "helpers"]
        },
        auction: {
            path: "../bridge/auction/auction.js",
            requires: ["widget", "mustache"]
        },
        hand: {
            path: "../bridge/hand/hand.js",
            requires: ["widget", "mustache", "collection", "helpers"]
        },
        trick: {
            path: "../bridge/trick/trick.js",
            requires: ["widget", "mustache"]
        },
        tricks: {
            path: "../bridge/tricks/tricks.js",
            requires: ["widget", "mustache", "helpers"]
        },
        table: {
            path: "../bridge/table/table.js",
            requires: ["base-base", "node", "json", "mustache", "hand", "biddingbox", "auction", "helpers", "trick", "tricks", "info", "claim", "claimpreview", "io"]
        },
        chat: {
            path: "../bridge/chat/chat.js",
            requires: ["widget", "mustache", "gallery-io-poller", "json"]
        }
    }
}).use("node", "table", function(Y) {
    if(Y.one("#table")) {
        new Y.Bridge.Table({ container: "#table" });
    }
});
