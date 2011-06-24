window.YUI_config = {
    filter: "raw",
    groups: {
        bridge: {
            base: "/assets/bridge/",
            modules: {
                card: {
                    path: "card/card.js",
                    requires: ["widget", "widget-child", "collection"],
                    skinnable: true
                }
            }
        }
    }
};
