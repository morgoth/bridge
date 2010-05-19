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
            requires: ["base-base", "node", "gallery-io-poller", "json", "mustache", "hand", "biddingbox", "auction", "helpers", "trick", "tricks", "info", "claim", "claimpreview"]
        },
        chat: {
            path: "../bridge/chat/chat.js",
            requires: ["widget", "mustache", "gallery-io-poller", "json"]
        },
        "gallery-io-poller": {
            path: "../yui3-gallery/gallery-io-poller/gallery-io-poller.js",
            requires: ["io-base", "base-base"]
        }
    }
}).use("node", "table", "chat", function(Y) {
    var userId, userName, tableId, channelId,
        userIdNode = Y.Node.one('meta[name="bridge-user-id"]'),
        userNameNode = Y.Node.one('meta[name="bridge-user-name"]'),
        chatNode = Y.Node.one("#chat"),
        tableNode = Y.Node.one("#table");

    userId = userIdNode && userIdNode.getAttribute("content");
    userName = userNameNode && userNameNode.getAttribute("content");
    channelId = chatNode && chatNode.getAttribute("data-channel-id");
    tableId = tableNode && tableNode.getAttribute("data-table-id");

    if(tableId) {
        new Y.Bridge.Table({ container: tableNode, userId: userId, id: tableId, pollTimeout: 5000 });
    }

    if(channelId) {
        new Y.Bridge.Chat({ contentBox: chatNode, channelId: channelId, name: userName, pollTimeout: 5000 }).render();
    }
});
