window.YUICONFIG = {
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
            requires: ["widget", "mustache", "collection", "helpers", "uihelper"]
        },
        claim: {
            path: "../bridge/claim/claim.js",
            requires: ["widget", "mustache", "uihelper"]
        },
        claimpreview: {
            path: "../bridge/claimpreview/claimpreview.js",
            requires: ["widget", "mustache", "uihelper"]
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
            requires: ["base-base", "node", "json", "mustache", "hand", "biddingbox", "auction", "helpers", "trick", "tricks", "info", "claim", "claimpreview", "io", "chat"]
        },
        chat: {
            path: "../bridge/chat/chat.js",
            requires: ["widget", "mustache"]
        },
        uihelper: {
            path: "../bridge/uihelper/uihelper.js",
            requires: ["widget", "mustache"]
        },
        instantaction: {
            path: "../bridge/instantaction/instantaction.js",
            requires: ["plugin", "oop"]
        },
        // TEST CASES
        "helpers-testcase": {
            path: "../test/helpers/helpers.js",
            requires: ["classnamemanager", "oop", "collection", "test", "console", "helpers"]
        },
        "biddingbox-testcase": {
            path: "../test/biddingbox/biddingbox.js",
            requires: ["test", "console", "node-event-simulate", "widget", "mustache", "collection", "helpers", "biddingbox"]
        },
        "claim-testcase": {
            path: "../test/claim/claim.js",
            requires: ["test", "console", "node-event-simulate", "widget", "mustache", "claim"]
        },
        "claimpreview-testcase": {
            path: "../test/claimpreview/claimpreview.js",
            requires: ["test", "console", "node-event-simulate", "widget", "mustache", "claimpreview"]
        }
    }
};
