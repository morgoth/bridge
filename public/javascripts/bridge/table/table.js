YUI.add("table", function(Y) {

    Y.namespace("Bridge");

    function Table() {
        Table.superclass.constructor.apply(this, arguments);
    };

    Y.extend(Table, Y.Base, {

        initializer: function() {
            this._parseTableId();
            this._parsePusherApiKey();
            this._renderUI();
            this._bindUI();
            this._parseChannelName();
            // this._io(this._tablePath());
        },

        _parseTableId: function() {
            var container = this.get("container");

            this.set("tableId", container.getAttribute("data-table-id"));
        },

        _parsePusherApiKey: function() {
            var container = this.get("container");

            this.set("pusherApiKey", container.getAttribute("data-pusher-api-key"));
        },

        _parseChannelName: function() {
            var container = this.get("container");

            this.set("channelName", container.getAttribute("data-channel-name"));
        },

        _renderUI: function() {
            this._renderTable();
            this._renderHands();
            this._renderBiddingBox();
            this._renderAuction();
            this._renderTrick();
            this._renderTricks();
            this._renderInfo();
            this._renderClaim();
            this._renderClaimPreview();
        },

        _bindUI: function() {
            this.on("hand:join", this._onHandJoin);
            this.on("hand:quit", this._onHandQuit);
            this.on("hand:card", this._onHandCard);
            this.on("biddingbox:bid", this._onBiddingBoxBid);
            this.on("claim:claim", this._onClaimClaim);
            // temporarily disabled
            // this.on("claim:cancel", this._onClaimCancel);
            this.on("claimpreview:accept", this._onClaimPreviewAccept);
            this.on("claimpreview:reject", this._onClaimPreviewReject);
            this.on("channelNameChange", this._onChannelNameChange);
            this.after("tableDataChange", this._afterTableDataChange);
            this.after("playerChange", this._afterPlayerChange);
            this.after("boardStateChange", this._afterBoardStateChange);
        },

        _onHandJoin: function(event) {
            var direction = event.target.get("direction");

            this._io(this._tablePlayerPath(), { method: "POST", data: "player[direction]=" + direction });
        },

        _onHandQuit: function(event) {
            this._io(this._tablePlayerPath(), { method: "POST", data: "_method=DELETE" });
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

        _io: function(uri, configuration) {
            configuration = configuration || {};
            configuration.on = configuration.on || {};
            configuration.on.start = Y.bind(this._onRequestStart, this);
            configuration.on.success = Y.bind(this._onRequestSuccess, this);
            configuration.on.failure = Y.bind(this._onRequestFailure, this);
            Y.io(uri, configuration);
        },

        _afterTableDataChange: function(event) {
            this._uiSyncTable(event.newVal);
        },

        _afterPlayerChange: function(event) {
            this._uiSetPlayer(event.newVal);
        },

        _afterBoardStateChange: function(event) {
            this._uiSetBoardState(event.newVal);
        },

        _onChannelNameChange: function(event) {
            if(event.prevVal !== event.newVal) {
                this._reconnect(event.prevVal, event.newVal);
            }
        },

        _onRequestStart: function() {
            window.READY = false;
        },

        _onRequestSuccess: function(id, response) {
            // if(/^application\/json/.test(response.getResponseHeader("Content-Type"))) {
            //     // this.set("tableData", Y.JSON.parse(response.responseText));
            //     this._uiSyncTable(Y.JSON.parse(response.responseText));
            // }
            if(Y.Lang.isString(response.responseText) && response.responseText !== "") {
                this._uiSyncTable(Y.JSON.parse(response.responseText));
            }
        },

        _onRequestFailure: function(id, response) {
            Y.log(response);
            alert("Error: communication problem occured, page reload might be required.");
        },

        _renderTable: function() {
            var container = this.get("container"),
                html = Y.mustache(Table.MAIN_TEMPLATE, {});

            container.set("innerHTML", html);
        },

        _renderHands: function() {
            var container = this.get("container");

            this.hands = Y.Array.map(Y.Bridge.DIRECTIONS, function(direction, i) {
                var handNode = container.one(".bridge-hand-" + direction.toLowerCase());

                return new Y.Bridge.Hand({
                    host: this,
                    direction: direction,
                    boundingBox: handNode,
                    visible: false
                }).render();
            }, this);
        },

        _renderBiddingBox: function() {
            var biddingBoxNode,
                container = this.get("container");
            biddingBoxNode = container.one(".bridge-biddingbox");

            this.biddingBox = new Y.Bridge.BiddingBox({
                host: this,
                boundingBox: biddingBoxNode,
                visible: false
            }).render();
        },

        _renderAuction: function() {
            var auctionNode,
                container = this.get("container");

            auctionNode = container.one(".bridge-auction");

            this.auction = new Y.Bridge.Auction({
                host: this,
                boundingBox: auctionNode,
                visible: false
            }).render();
        },

        _renderTrick: function() {
            var trickNode,
                container = this.get("container");

            trickNode = container.one(".bridge-trick");

            this.trick = new Y.Bridge.Trick({
                host: this,
                boundingBox: trickNode,
                visible: false
            }).render();
        },

        _renderTricks: function() {
            var tricksNode,
                container = this.get("container");
            tricksNode = container.one(".bridge-tricks");

            this.tricks = new Y.Bridge.Tricks({
                host: this,
                boundingBox: tricksNode,
                visible: false
            }).render();
        },

        _renderInfo: function() {
            var infoNode,
                container = this.get("container");
            infoNode = container.one(".bridge-info");

            this.info = new Y.Bridge.Info({
                host: this,
                boundingBox: infoNode,
                visible: false
            }).render();
        },

        _renderClaim: function() {
            var claimNode,
                container = this.get("container");
            claimNode = container.one(".bridge-claim");

            this.claim = new Y.Bridge.Claim({
                host: this,
                boundingBox: claimNode,
                visible: false
            }).render();
        },

        _renderClaimPreview: function() {
            var claimPreviewNode,
                container = this.get("container");
            claimPreviewNode = container.one(".bridge-claimpreview");

            this.claimPreview = new Y.Bridge.ClaimPreview({
                host: this,
                boundingBox: claimPreviewNode,
                visible: false
            }).render();
        },

        _uiSyncTable: function(tableData) {
            if(this.get("tableVersion") < tableData.tableVersion) {
                Y.log("table: syncing to version " + tableData.tableVersion);
                this.set("player", tableData.player);
                this.set("boardState", tableData.boardState);
                this.set("channelName", tableData.channelName);
                this.set("tableVersion", tableData.tableVersion);
                this._uiSyncHands(tableData.hands);
                this.biddingBox.setAttrs(tableData.biddingBox);
                this.auction.setAttrs(tableData.auction);
                this.trick.setAttrs(tableData.trick);
                this.tricks.setAttrs(tableData.tricks);
                this.info.setAttrs(tableData.info);
                this.claim.setAttrs(tableData.claim);
                this.claimPreview.setAttrs(tableData.claimPreview);
            }
        },

        _uiSetPlayer: function(player) {
            var handNodes, slotNodes,
                position = Y.Bridge.dealerPosition(player),
                container = this.get("container");
            handNodes = [
                container.one(".bridge-hand-n"),
                container.one(".bridge-hand-e"),
                container.one(".bridge-hand-s"),
                container.one(".bridge-hand-w")
            ];
            slotNodes = [
                container.one(".bridge-table-row-1 .bridge-table-col-2"),
                container.one(".bridge-table-row-2 .bridge-table-col-3"),
                container.one(".bridge-table-row-3 .bridge-table-col-2"),
                container.one(".bridge-table-row-2 .bridge-table-col-1")
            ];

            this.trick.set("player", player);
            this.tricks.set("player", player);
            this.info.set("player", player);

            Y.each(slotNodes, function(slotNode, i) {
                slotNode.append(handNodes[(i + position + 2) % 4]);
            }, this);
        },

        _uiSetBoardState: function(boardState) {
            var auctionNode, auctionSlotNodes,
                container = this.get("container");
            auctionNode = container.one(".bridge-auction");
            auctionSlotNodes = [
                container.one(".bridge-table-row-1 .bridge-table-col-3"),
                container.one(".bridge-table-row-2 .bridge-table-col-2")
            ];

            switch(boardState) {
            case "preparing":
                auctionSlotNodes[0].append(auctionNode);
                break;
            case "auction":
                auctionSlotNodes[1].append(auctionNode);
                break;
            case "playing":
                auctionSlotNodes[0].append(auctionNode);
                break;
            }
        },

        _uiSyncHands: function(hands) {
            Y.each(hands, function(hand, i) {
                this.hands[i].setAttrs(hand);
            }, this);
        },

        _reconnect: function(oldChannelName, newChannelName) {
            var that = this;

            if(this.pusher === undefined) {
                this.pusher = new Pusher(this.get("pusherApiKey"));

                this.pusher.bind("connection_established", function() {
                    that._io(that._tablePath());
                });
            }

            if(Y.Lang.isString(oldChannelName)) {
                Y.log("reconnect: unsubscribing from " + oldChannelName);
                that.pusher.unsubscribe(oldChannelName);
            }

            this.pusher.subscribe(newChannelName).bind("update-table-data", function(data) {
                that._uiSyncTable(data);
            });

            Y.log("reconnect: subscribing to " + newChannelName);
        }

    }, {

        NAME: "table",

        ATTRS: {

            tableId: {
                setter: parseInt
            },

            tableVersion: {
                setter: parseInt,
                value: -1
            },

            channelName: {

            },

            pusherApiKey: {

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

            container: {
                value: "body",
                setter: function(selector) {
                    return Y.one(selector);
                }
            }

        },

        TABLE_PATH: "/ajax/tables/{{tableId}}.json",
        TABLE_PLAYER_PATH: "/ajax/tables/{{tableId}}/player",
        TABLE_BIDS_PATH: "/ajax/tables/{{tableId}}/bids",
        TABLE_CARDS_PATH: "/ajax/tables/{{tableId}}/cards",
        TABLE_CLAIMS_PATH: "/ajax/tables/{{tableId}}/claims",
        TABLE_ACCEPT_CLAIM_PATH: "/ajax/tables/{{tableId}}/claims/{{claimId}}/accept",
        TABLE_REJECT_CLAIM_PATH: "/ajax/tables/{{tableId}}/claims/{{claimId}}/reject",

        MAIN_TEMPLATE: ''
            + '<div class="bridge-table">'
            +   '<div class="bridge-table-row-1">'
            +     '<div class="bridge-table-col-1">'
            +       '<div class="bridge-info"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-2">'
            +       '<div class="bridge-hand-n"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-3">'
            +       '<div class="bridge-auction"></div>'
            +     '</div>'
            +   '</div>'
            +   '<div class="bridge-table-row-2">'
            +     '<div class="bridge-table-col-1">'
            +       '<div class="bridge-hand-w"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-2">'
            +       '<div class="bridge-trick"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-3">'
            +       '<div class="bridge-hand-e"></div>'
            +     '</div>'
            +   '</div>'
            +   '<div class="bridge-table-row-3">'
            +     '<div class="bridge-table-col-1">'
            +       '<div class="bridge-claim"></div>'
            +       '<div class="bridge-claimpreview"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-2">'
            +       '<div class="bridge-hand-s"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-3">'
            +       '<div class="bridge-biddingbox"></div>'
            +       '<div class="bridge-tricks"></div>'
            +     '</div>'
            +   '</div>'
            + '</div>'

    });

    Y.Bridge.Table = Table;

}, "0", { requires: ["base", "node", "json", "mustache", "hand", "biddingbox", "auction", "trick", "tricks", "info", "claim", "claimpreview"] });
