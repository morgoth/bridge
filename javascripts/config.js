window.YUI_config = {
    filter: "raw",
    groups: {
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
                    requires: ["widget"],
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
                "helpers": {
                    path: "helpers/helpers.js"
                }
            }
        }
    }
};
