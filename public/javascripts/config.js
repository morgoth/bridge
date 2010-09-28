window.YUICONFIG = {
    filter: "raw",
    groups: {
        gallery: {
            base: "/javascripts/gallery/",
            modules: {
                "gallery-preload": {
                    path: "gallery-preload/gallery-preload.js"
                }
            }
        },
        bridge: {
            base: "/javascripts/bridge/",
            modules: {
                mustache: {
                    path: "mustache/mustache.js"
                },
                helpers: {
                    path: "helpers/helpers.js",
                    requires: ["collection", "oop", "classnamemanager", "mustache"]
                },
                biddingbox: {
                    path: "biddingbox/biddingbox.js",
                    requires: ["widget", "mustache", "collection", "helpers", "uihelper"]
                },
                claim: {
                    path: "claim/claim.js",
                    requires: ["widget", "mustache", "uihelper"]
                },
                claimpreview: {
                    path: "claimpreview/claimpreview.js",
                    requires: ["widget", "mustache", "uihelper"]
                },
                info: {
                    path: "info/info.js",
                    requires: ["widget", "mustache", "helpers", "uihelper"]
                },
                bid: {
                    path: "bid/bid.js",
                    requires: ["widget", "widget-child", "mustache"],
                    skinnable: true
                },
                auction: {
                    path: "auction/auction.js",
                    requires: ["widget", "widget-parent", "mustache", "bid"],
                    skinnable: true
                },
                card: {
                    path: "card/card.js",
                    requires: ["widget", "widget-child", "mustache"],
                    skinnable: true
                },
                cardlist: {
                    path: "cardlist/cardlist.js",
                    requires: ["widget", "widget-parent", "card"]
                },
                hand: {
                    path: "hand/hand.js",
                    requires: ["cardlist", "collection"],
                    skinnable: true
                },
                trick: {
                    path: "trick/trick.js",
                    requires: ["cardlist", "mustache", "helpers"],
                    skinnable: true
                },
                tricks: {
                    path: "tricks/tricks.js",
                    requires: ["widget", "mustache", "helpers", "uihelper"],
                    skinnable: true
                },
                table: {
                    path: "table/table.js",
                    requires: ["widget", "node", "json", "mustache", "hand", "biddingbox", "auction", "helpers", "trick", "tricks", "info", "claim", "claimpreview", "io", "chat"],
                    skinnable: true
                },
                chat: {
                    path: "chat/chat.js",
                    requires: ["widget", "mustache", "uihelper"]
                },
                uihelper: {
                    path: "uihelper/uihelper.js",
                    requires: ["widget", "mustache"]
                },
                instantaction: {
                    path: "instantaction/instantaction.js",
                    requires: ["plugin", "oop"]
                },
                // TEST CASES
                "helpers-testcase": {
                    path: "helpers/helpers.js",
                    requires: ["classnamemanager", "oop", "collection", "test", "console", "helpers"]
                },
                "biddingbox-testcase": {
                    path: "biddingbox/biddingbox.js",
                    requires: ["test", "console", "node-event-simulate", "widget", "mustache", "collection", "helpers", "biddingbox"]
                },
                "claim-testcase": {
                    path: "claim/claim.js",
                    requires: ["test", "console", "node-event-simulate", "widget", "mustache", "claim"]
                },
                "claimpreview-testcase": {
                    path: "claimpreview/claimpreview.js",
                    requires: ["test", "console", "node-event-simulate", "widget", "mustache", "claimpreview"]
                }
            }
        }
    }
};
