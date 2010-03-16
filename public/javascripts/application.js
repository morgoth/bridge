YUI({
    filter: "raw",
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
}).use("node", "table", function(Y) {
    var userId, tableId,
        tableSelector = "#table",
        userNode = Y.Node.one('meta[name="bridge-user-id"]'),
        tableNode = Y.Node.one(tableSelector);

    userId = userNode && userNode.getAttribute("content");
    tableId = tableNode && tableNode.getAttribute("data-table-id");

    if(tableId) {
        new Y.Bridge.Table({ container: tableSelector, userId: userId, id: tableId });
    }
});
