window.YUI_config = {
    filter: "raw",
    groups: {
        "gallery": {
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
        "bridge-model": {
            base: "/assets/bridge/model/",
            modules: {
                "sync": {
                    path: "sync/sync.js",
                    requires: ["io", "querystring-stringify"]
                },
                "bid-model": {
                    path: "bid/bid.js",
                    requires: ["model", "sync"]
                },
                "bid-model-list": {
                    path: "bidlist/bidlist.js",
                    requires: ["model-list", "bid-model", "collection"]
                },
                "board-model": {
                    path: "board/board.js",
                    requires: ["model", "bid-model-list", "card-model-list"]
                },
                "card-model": {
                    path: "card/card.js",
                    requires: ["model"]
                },
                "card-model-list": {
                    path: "cardlist/cardlist.js",
                    requires: ["model-list", "card-model", "collection"]
                },
                "player-model": {
                    path: "player/player.js",
                    requires: ["model"]
                },
                "player-model-list": {
                    path: "playerlist/playerlist.js",
                    requires: ["model-list", "player-model"]
                },
                "table-model": {
                    path: "table/table.js",
                    requires: ["model", "board-model", "player-model-list", "sync"]
                }
            }
        },
        "bridge": {
            base: "/assets/bridge/",
            modules: {
                "table": {
                    path: "table/table.js",
                    requires: ["widget", "hand", "auction", "biddingbox", "trick"],
                    skinnable: true
                },
                "card": {
                    path: "card/card.js",
                    requires: ["widget", "widget-child"],
                    skinnable: true
                },
                "hand": {
                    path: "hand/hand.js",
                    requires: ["widget", "handcards", "handbar"],
                    skinnable: true
                },
                "handbar": {
                    path: "hand/handbar.js",
                    requires: ["widget"]
                },
                "handcards": {
                    path: "hand/handcards.js",
                    requires: ["widget", "widget-parent", "card"]
                },
                "biddingbox": {
                    path: "biddingbox/biddingbox.js",
                    requires: ["passbox", "bidbox", "alertbox"],
                    skinnable: true
                },
                "passbox": {
                    path: "biddingbox/passbox.js",
                    requires: ["gallery-button", "gallery-button-group"],
                    skinnable: true
                },
                "bidbox": {
                    path: "biddingbox/bidbox.js",
                    requires: ["bidboxsuits", "bidboxlevels"],
                    skinnable: true
                },
                "bidboxlevels": {
                    path: "biddingbox/bidboxlevels.js",
                    requires: ["gallery-button-toggle", "gallery-button-group"],
                    skinnable: true
                },
                "bidboxsuits": {
                    path: "biddingbox/bidboxsuits.js",
                    requires: ["gallery-button", "gallery-button-group"],
                    skinnable: true
                },
                "alertbox": {
                    path: "biddingbox/alertbox.js",
                    requires: ["event-valuechange", "gallery-button-toggle"],
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
                "tricks": {
                    path: "tricks/tricks.js",
                    requires: ["tricksbar", "widget-parent", "helpers"],
                    skinnable: true
                },
                "trickstrick": {
                    path: "tricks/trickstrick.js",
                    requires: ["widget", "widget-child"]
                },
                "tricksbar": {
                    path: "tricks/tricksbar.js",
                    requires: ["trickstrick", "widget-parent", "helpers"]
                },
                "auction": {
                    path: "auction/auction.js",
                    requires: ["widget", "widget-parent", "auctionbid"],
                    skinnable: true
                },
                "auctionbid": {
                    path: "auction/auctionbid.js",
                    requires: ["gallery-button", "helpers"]
                },
                "helpers": {
                    path: "helpers/helpers.js"
                }
            }
        }
    }
};
