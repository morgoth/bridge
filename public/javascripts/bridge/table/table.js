YUI.add("table", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Table = Y.Base.create("table", Y.Widget, [], {

        renderUI: function() {
            this._renderTable();
            this._renderHands();
            this._renderBiddingBox();
            this._renderAuction();
            this._renderTrick();
            this._renderTricks();
            this._renderInfo();
            this._renderClaim();
            this._renderClaimPreview();
            this._renderBar();
            this._renderChat();
        },

        bindUI: function() {
            this.on("bar:quit", this._onBarQuit);
            this.on("bar:claim", this._onBarClaim);
            this.on("chat:message", this._onChatMessage);
            this.on("hand:join", this._onHandJoin);
            this.on("card:card", this._onHandCard);
            this.on("biddingbox:bid", this._onBiddingBoxBid);
            this.on("claim:claim", this._onClaimClaim);
            this.on("claim:cancel", this._onClaimCancel);
            this.on("claimpreview:accept", this._onClaimPreviewAccept);
            this.on("claimpreview:reject", this._onClaimPreviewReject);
            this.after("tableDataChange", this._afterTableDataChange);
            this.after("playerChange", this._afterPlayerChange);
            this.after("boardStateChange", this._afterBoardStateChange);
            this.after("connectedChange", this._afterConnectedChange);
            this.after("ioLockChange", this._afterIoLockChange);
            this.after("messageReceived", this._afterMessageReceived);
        },

        syncUI: function() {
            this._connect();
        },

        _onHandJoin: function(event) {
            var direction = event.target.get("direction");

            this._io(this._tablePlayerPath(), { method: "POST", data: "player[direction]=" + direction });
        },

        _onBarQuit: function(event) {
            this._io(this._tablePlayerPath(), { method: "POST", data: "_method=DELETE" });
        },

        _onBarClaim: function(event) {
            this.claim.show();
        },

        _onBiddingBoxBid: function(event) {
            var bid = event[0],
                alert = event[1];

            this._io(this._tableBidsPath(), {
                method: "POST",
                data: "bid[bid]=" + bid + "&" + "bid[alert]=" + encodeURIComponent(alert)
            });
        },

        _onHandCard: function(event) {
            var card = event[0];

            this._io(this._tableCardsPath(), { method: "POST", data: "card[card]=" + card });
        },

        _onClaimClaim: function(event) {
            var tricks = event[0],
                explanation = event[1];

            this._io(this._tableClaimsPath(), {
                method: "POST",
                data: "claim[tricks]=" + tricks + "&" + "claim[explanation]=" + encodeURIComponent(explanation)
            });
        },

        _onClaimCancel: function(event) {
            event.target.hide();
        },

        _onChatMessage: function(event) {
            var body = event[0];

            this._io(this._tableMessagesPath(), {
                method: "POST",
                data: "message[body]=" + encodeURIComponent(body)
            });
        },

        _onClaimPreviewAccept: function(event) {
            var id = event[0];

            this._io(this._tableAcceptClaimPath(id), { method: "POST", data: "_method=PUT" });
        },

        _onClaimPreviewReject: function(event) {
            var id = event[0];

            this._io(this._tableRejectClaimPath(id), { method: "POST", data: "_method=PUT" });
        },

        _tablePath: function() {
            return Y.mustache(Table.TABLE_PATH, { tableId: this.get("tableId") });
        },

        _tablePlayerPath: function() {
            return Y.mustache(Table.TABLE_PLAYER_PATH, { tableId: this.get("tableId") });
        },

        _tableBidsPath: function() {
            return Y.mustache(Table.TABLE_BIDS_PATH, { tableId: this.get("tableId") });
        },

        _tableCardsPath: function() {
            return Y.mustache(Table.TABLE_CARDS_PATH, { tableId: this.get("tableId") });
        },

        _tableClaimsPath: function() {
            return Y.mustache(Table.TABLE_CLAIMS_PATH, { tableId: this.get("tableId") });
        },

        _tableAcceptClaimPath: function(claimId) {
            return Y.mustache(Table.TABLE_ACCEPT_CLAIM_PATH, { tableId: this.get("tableId"), claimId: claimId });
        },

        _tableRejectClaimPath: function(claimId) {
            return Y.mustache(Table.TABLE_REJECT_CLAIM_PATH, { tableId: this.get("tableId"), claimId: claimId });
        },

        _tableMessagesPath: function() {
            return Y.mustache(Table.TABLE_MESSAGES_PATH, { tableId: this.get("tableId") });
        },

        _io: function(uri, configuration) {
            configuration = configuration || {};
            configuration.on = configuration.on || {};
            configuration.on.start = Y.bind(this._onRequestStart, this);
            configuration.on.success = Y.bind(this._onRequestSuccess, this);
            configuration.on.failure = Y.bind(this._onRequestFailure, this);
            configuration.on.end = Y.bind(this._onRequestEnd, this);

            if(!this.get("ioLock")) {
                Y.io(uri, configuration);
            }
        },

        _afterTableDataChange: function(event) {
            this._uiSyncTable(event.newVal, event.force);
        },

        _afterPlayerChange: function(event) {
            this._uiSetPlayer(event.newVal);
        },

        _afterBoardStateChange: function(event) {
            this._uiSetBoardState(event.newVal);
        },

        _afterConnectedChange: function(event) {
            this.chat.addMessage("bridge", "successfully connected");
        },

        _afterIoLockChange: function(event) {
            this.chat.set("disabled", event.newVal || !Y.Lang.isValue(this.get("userId")));
            window.READY = !event.newVal;
        },

        _onRequestStart: function() {
            this.set("ioLock", true);
        },

        _onRequestSuccess: function(id, response) {
            if(Y.Lang.isString(response.responseText) && Y.Lang.trim(response.responseText) !== "") {
                this.set("tableData", Y.JSON.parse(response.responseText), { force: true });
            }
        },

        _onRequestFailure: function(id, response) {
            Y.log(response);
            this._uiSyncTable(this.get("tableData"), true);
            alert("Error: communication problem occured, page reload might be required.");
        },

        _onRequestEnd: function() {
            this.set("ioLock", false);
        },

        _renderTable: function() {
            this.get("contentBox").setContent(Y.mustache(Table.MAIN_TEMPLATE, Table));
        },

        _renderHands: function() {
            this.hands = Y.Array.map(Y.Bridge.DIRECTIONS, function(direction, i) {
                return new Y.Bridge.Hand({
                    host: this,
                    direction: direction,
                    userId: this.get("userId"),
                    visible: false
                }).render(this.get("contentBox").one(DOT + Table["C_HAND_" + direction]));
            }, this);
        },

        _renderBiddingBox: function() {
            this.biddingBox = new Y.Bridge.BiddingBox({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_BIDDINGBOX));
        },

        _renderAuction: function() {
            this.auction = new Y.Bridge.Auction({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_AUCTION));
        },

        _renderTrick: function() {
            this.trick = new Y.Bridge.Trick({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_TRICK));
        },

        _renderTricks: function() {
            this.tricks = new Y.Bridge.Tricks({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_TRICKS));
        },

        _renderInfo: function() {
            this.info = new Y.Bridge.Info({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_INFO));
        },

        _renderClaim: function() {
            this.claim = new Y.Bridge.Claim({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_CLAIM));
        },

        _renderClaimPreview: function() {
            this.claimPreview = new Y.Bridge.ClaimPreview({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_CLAIMPREVIEW));
        },

        _renderBar: function() {
            this.bar = new Y.Bridge.Bar({
                host: this,
                visible: false
            }).render(this.get("contentBox").one(DOT + Table.C_BAR));
        },

        _renderChat: function() {
            this.chat = new Y.Bridge.Chat({
                host: this,
                disabled: true
            }).render(this.get("contentBox").one(DOT + Table.C_CHAT));

            this.chat.addMessage("bridge", "connecting...");
        },

        _uiSyncTable: function(tableData, force) {
            var tableVersion = this.get("tableVersion");

            if(force || (tableVersion < tableData.tableVersion)) {
                Y.log("table: syncing to version " + tableData.tableVersion + ", forced: " + !!force);
                this.set("connected", true);
                this.set("player", tableData.player);
                this.set("boardState", tableData.boardState);
                this.set("tableVersion", tableData.tableVersion);
                this._uiSyncHands(tableData.hands);
                this.biddingBox.setAttrs(tableData.biddingBox);
                this.auction.setAttrs(tableData.auction);
                this.trick.setAttrs(tableData.trick);
                this.tricks.setAttrs(tableData.tricks);
                this.info.setAttrs(tableData.info);
                this.claim.setAttrs(tableData.claim);
                this.claimPreview.setAttrs(tableData.claimPreview);
                this.bar.setAttrs(tableData.bar);
            }
        },

        _afterMessageReceived: function(event) {
            var data = event[0];

            this.chat.addMessage(data.name, data.body);
        },

        _uiSetPlayer: function(player) {
            var handNodes, slotNodes,
                position = Y.Bridge.dealerPosition(player),
                contentBox = this.get("contentBox");
            handNodes = [
                contentBox.one(DOT + Table.C_HAND_N),
                contentBox.one(DOT + Table.C_HAND_E),
                contentBox.one(DOT + Table.C_HAND_S),
                contentBox.one(DOT + Table.C_HAND_W)
            ];
            slotNodes = [
                contentBox.one(DOT + Table.C_ROW_1).one(DOT + Table.C_COL_2),
                contentBox.one(DOT + Table.C_ROW_2).one(DOT + Table.C_COL_3),
                contentBox.one(DOT + Table.C_ROW_3).one(DOT + Table.C_COL_2),
                contentBox.one(DOT + Table.C_ROW_2).one(DOT + Table.C_COL_1)
            ];

            this.trick.set("player", player);
            this.tricks.set("player", player);
            this.info.set("player", player);

            Y.each(slotNodes, function(slotNode, i) {
                slotNode.append(handNodes[(i + position + 2) % 4]);
            }, this);
        },

        _uiSetBoardState: function(boardState) {
            var auctionNode, slotNodes,
                contentBox = this.get("contentBox");
            auctionNode = contentBox.one(DOT + Table.C_AUCTION);
            slotNodes = [
                contentBox.one(DOT + Table.C_ROW_1).one(DOT + Table.C_COL_3),
                contentBox.one(DOT + Table.C_ROW_2).one(DOT + Table.C_COL_2)
            ];

            switch(boardState) {
            case "preparing":
                slotNodes[0].append(auctionNode);
                break;
            case "auction":
                slotNodes[1].append(auctionNode);
                break;
            case "playing":
                slotNodes[0].append(auctionNode);
                break;
            }
        },

        _uiSyncHands: function(hands) {
            Y.each(hands, function(hand, i) {
                this.hands[i].setAttrs(hand);
            }, this);
        },

        _connect: function() {
            var options = { log: true },
                channelName = "table-" + this.get("tableId"),
                userId = this.get("userId"),
                that = this;

            if(Y.Lang.isValue(this.get("userId"))) {
                options.user = userId;
            }

            Beacon.connect(this.get("beaconpushApiKey"), [channelName], options);
            Beacon.listen(function (data) {
                that.set("tableData", Y.JSON.parse(data));
            });

            this._io(this._tablePath());

            Y.log("connect: subscribing to " + channelName);
        }

    }, {

        HTML_PARSER: {

            tableId: function(srcNode) {
                return srcNode.getAttribute("data-table-id");
            },

            userId: function(srcNode) {
                return srcNode.getAttribute("data-user-id");
            },

            beaconpushApiKey: function(srcNode) {
                return srcNode.getAttribute("data-beaconpush-api-key");
            }

        },

        ATTRS: {

            tableId: {
                setter: parseInt
            },

            userId: {
                setter: parseInt
            },

            tableVersion: {
                setter: parseInt,
                value: -1
            },

            beaconpushApiKey: {

            },

            player: {
                setter: function(player) {
                    return Y.Bridge.isDirection(player) ? player : "S";
                }
            },

            tableData: {

            },

            boardState: {

            },

            ioLock: {

            },

            connected: {

            }

        },

        TABLE_PATH: "/ajax/tables/{{tableId}}.json",
        TABLE_PLAYER_PATH: "/ajax/tables/{{tableId}}/player",
        TABLE_BIDS_PATH: "/ajax/tables/{{tableId}}/bids",
        TABLE_CARDS_PATH: "/ajax/tables/{{tableId}}/cards",
        TABLE_MESSAGES_PATH: "/ajax/tables/{{tableId}}/messages",
        TABLE_CLAIMS_PATH: "/ajax/tables/{{tableId}}/claims",
        TABLE_ACCEPT_CLAIM_PATH: "/ajax/tables/{{tableId}}/claims/{{claimId}}/accept",
        TABLE_REJECT_CLAIM_PATH: "/ajax/tables/{{tableId}}/claims/{{claimId}}/reject",

        C_ROW_1:        getClassName("table", "row", "1"),
        C_ROW_2:        getClassName("table", "row", "2"),
        C_ROW_3:        getClassName("table", "row", "3"),
        C_COL_1:        getClassName("table", "col", "1"),
        C_COL_2:        getClassName("table", "col", "2"),
        C_COL_3:        getClassName("table", "col", "3"),
        C_INFO:         getClassName("table", "info"),
        C_HAND_N:       getClassName("table", "hand", "n"),
        C_HAND_E:       getClassName("table", "hand", "e"),
        C_HAND_S:       getClassName("table", "hand", "s"),
        C_HAND_W:       getClassName("table", "hand", "w"),
        C_CLAIM:        getClassName("table", "claim"),
        C_CLAIMPREVIEW: getClassName("table", "claimpreview"),
        C_TRICK:        getClassName("table", "trick"),
        C_AUCTION:      getClassName("table", "auction"),
        C_BIDDINGBOX:   getClassName("table", "biddingbox"),
        C_TRICKS:       getClassName("table", "tricks"),
        C_BAR:          getClassName("table", "bar"),
        C_CHAT:         getClassName("table", "chat"),

        MAIN_TEMPLATE: ''
            + '<div class="{{C_ROW_1}}">'
            +   '<div class="{{C_COL_1}} yui3-u-1-3">'
            +     '<div class="{{C_INFO}}"></div>'
            +   '</div>'
            +   '<div class="{{C_COL_2}} yui3-u-1-3">'
            +     '<div class="{{C_HAND_N}}"></div>'
            +   '</div>'
            +   '<div class="{{C_COL_3}} yui3-u-1-3">'
            +     '<div class="{{C_AUCTION}}"></div>'
            +   '</div>'
            + '</div>'
            + '<div class="{{C_ROW_2}}">'
            +   '<div class="{{C_COL_1}} yui3-u-1-3">'
            +     '<div class="{{C_HAND_W}}"></div>'
            +   '</div>'
            +   '<div class="{{C_COL_2}} yui3-u-1-3">'
            +     '<div class="{{C_TRICK}}"></div>'
            +   '</div>'
            +   '<div class="{{C_COL_3}} yui3-u-1-3">'
            +     '<div class="{{C_HAND_E}}"></div>'
            +   '</div>'
            + '</div>'
            + '<div class="{{C_ROW_3}}">'
            +   '<div class="{{C_COL_1}} yui3-u-1-3">'
            +     '<div class="{{C_CLAIM}}"></div>'
            +     '<div class="{{C_CLAIMPREVIEW}}"></div>'
            +   '</div>'
            +   '<div class="{{C_COL_2}} yui3-u-1-3">'
            +     '<div class="{{C_HAND_S}}"></div>'
            +   '</div>'
            +   '<div class="{{C_COL_3}} yui3-u-1-3">'
            +     '<div class="{{C_BIDDINGBOX}}"></div>'
            +     '<div class="{{C_TRICKS}}"></div>'
            +   '</div>'
            + '</div>'
            + '<div class="{{C_BAR}} yui3-u-1"></div>'
            + '<div class="{{C_CHAT}} yui3-u-1"></div>'

    });

    Y.Bridge.Table = Table;

}, "0", { requires: ["widget", "node", "json", "mustache", "hand", "biddingbox", "auction", "trick", "tricks", "info", "claim", "claimpreview", "io", "chat", "bar"] });
