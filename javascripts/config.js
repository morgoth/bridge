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
                "card-list": {
                    path: "cardlist/cardlist.js",
                    requires: ["widget", "widget-parent", "card"]
                },
                "hand": {
                    path: "hand/hand.js",
                    requires: ["card-list", "collection"],
                    skinnable: true
                }
            }
        }
    }
};
