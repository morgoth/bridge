window.YUI_config = {
    filter: "raw",
    groups: {
        bridge: {
            base: "/assets/bridge/",
            modules: {
                "card": {
                    path: "card/card.js",
                    requires: ["widget", "widget-child", "collection"],
                    skinnable: true
                },
                "cardlist": {
                    path: "cardlist/cardlist.js",
                    requires: ["widget", "widget-parent", "card"]
                },
                "hand": {
                    path: "hand/hand.js",
                    requires: ["cardlist", "handbar"],
                    skinnable: true
                },
                "handbar": {
                    path: "handbar/handbar.js",
                    requires: ["widget"],
                    skinnable: true
                }
            }
        }
    }
};
