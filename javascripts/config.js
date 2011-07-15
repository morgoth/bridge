window.YUI_config = {
    filter: "raw",
    groups: {
        gallery: {
            base: "/assets/gallery/",
            modules: {
                "gallery-button": {
                    path: "gallery-button/gallery-button.js",
                    requires: ["widget","event-mouseenter","widget-child"]
                },
                "gallery-button-toggle": {
                    path: "gallery-button-toggle/gallery-button-toggle.js",
                    requires: ["gallery-button"]
                },
                "gallery-button-group": {
                    path: "gallery-button-group/gallery-button-group.js",
                    requires: ["widget-parent","widget-child"]
                }
            }
        },
        bridge: {
            base: "/assets/bridge/",
            modules: {
                "card": {
                    path: "card/card.js",
                    requires: ["widget", "widget-child"],
                    skinnable: true
                },
                "cardlist": {
                    path: "card/cardlist.js",
                    requires: ["widget", "widget-parent", "card"]
                },
                "hand": {
                    path: "hand/hand.js",
                    requires: ["cardlist", "handbar"],
                    skinnable: true
                },
                "handbar": {
                    path: "hand/handbar.js",
                    requires: ["widget"]
                },
                "biddingbox": {
                    path: "biddingbox/biddingbox.js",
                    requires: ["passbox"],
                    skinnable: true
                },
                "passbox": {
                    path: "biddingbox/passbox.js",
                    requires: ["gallery-button", "gallery-button-group"],
                    skinnable: true
                },
                "trick": {
                    path: "trick/trick.js",
                    requires: ["widget", "widget-parent", "trickcard", "helpers"],
                    skinnable: true
                },
                "trickcard": {
                    path: "trick/trickcard.js",
                    requires: ["card"]
                },
                "auction": {
                    path: "auction/auction.js",
                    requires: ["widget", "widget-parent", "auctionbid"],
                    skinnable: true
                },
                "auctionbid": {
                    path: "auction/auctionbid.js",
                    requires: ["gallery-button"]
                },
                "helpers": {
                    path: "helpers/helpers.js"
                }
            }
        }
    }
};
