YUI.add("table", function(Y) {

    Y.namespace("Bridge");

    function Table() {
        Table.superclass.constructor.apply(this, arguments);
    };

    Y.extend(Table, Y.Base, {

        initializer: function() {
            this._renderUI();
            this._bindUI();
            this._initializePoll();
            this.poll.start();
        },

        _renderUI: function() {
            this._renderTable();
            this._renderHands();
            this._renderBiddingBox();
            this._renderAuction();
            this._renderTrick();
        },

        _bindUI: function() {
            this.on("hand:join", this._onHandJoin);
            this.on("hand:quit", this._onHandQuit);
            this.on("hand:card", this._onHandCard);
            this.on("biddingbox:bid", this._onBiddingBoxBid);
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
            var bid = event[0];

            this._io(this._tableBidsPath(), { method: "POST", data: "bid[bid]=" + bid });
        },

        _onHandCard: function(event) {
            var card = event[0];

            this._io(this._tableCardsPath(), { method: "POST", data: "card[card]=" + card });
        },

        _tablePlayerPath: function() {
            return Y.mustache(Table.TABLE_PLAYER_PATH, {
                id: this.get("id")
            });
        },

        _tableBidsPath: function() {
            return Y.mustache(Table.TABLE_BIDS_PATH, {
                id: this.get("id")
            });
        },

        _tableCardsPath: function() {
            return Y.mustache(Table.TABLE_CARDS_PATH, {
                id: this.get("id")
            });
        },

        _io: function(uri, configuration) {
            configuration = configuration || {};
            configuration.on = configuration.on || {};
            configuration.on.start = Y.bind(this._onRequestStart, this);
            configuration.on.success = Y.bind(this._onRequestSuccess, this);
            configuration.on.failure = Y.bind(this._onRequestFailure, this);

            this.poll.stop();
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

        _onRequestStart: function() {
            window.READY = false;
        },

        _onRequestSuccess: function() {
            this.poll.start();
        },

        _onRequestFailure: function(id, response) {
            Y.log(response);
            alert("Error: communication problem occured, page reload might be required.");
            this.poll.start();
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

                return new Y.Bridge.Hand({ host: this, direction: direction, boundingBox: handNode }).render();
            }, this);
        },

        _renderBiddingBox: function() {
            var biddingBoxNode,
                container = this.get("container");
            biddingBoxNode = container.one(".bridge-biddingbox");

            this.biddingBox = new Y.Bridge.BiddingBox({ host: this, boundingBox: biddingBoxNode }).render();
        },

        _renderAuction: function() {
            var auctionNode,
                container = this.get("container");

            auctionNode = container.one(".bridge-auction");

            this.auction = new Y.Bridge.Auction({ host: this, boundingBox: auctionNode }).render();
        },

        _renderTrick: function() {
            var trickNode,
                container = this.get("container");

            trickNode = container.one(".bridge-trick");

            this.trick = new Y.Bridge.Trick({ host: this, boundingBox: trickNode }).render();
        },

        _uiSyncTable: function(tableData) {
            this.set("player", tableData.player);
            this.set("boardState", tableData.boardState);
            this._uiSyncHands(tableData.hands);
            this.biddingBox.setAttrs(tableData.biddingBox);
            this.auction.setAttrs(tableData.auction);
            this.trick.setAttrs(tableData.trick);
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

        _initializePoll: function() {
            var timeout = this.get("pollTimeout"),
                tablePath = Y.mustache(Table.TABLE_PATH, {
                    id: this.get("id"),
                    user_id: this.get("userId")
                });

            this.poll = Y.io.poll(timeout, tablePath, {
                on: {
                    start: Y.bind(this._onPollStart, this),
                    modified: Y.bind(this._onPollModified, this),
                    failure: Y.bind(this._onPollFailure, this),
                    complete: Y.bind(this._onPollComplete, this)
                }
            });
        },

        _onPollStart: function(id, o) {
            window.READY = false;
        },

        _onPollModified: function(id, o) {
            var tableData = Y.JSON.parse(o.responseText);

            this.set("tableData", tableData);
        },

        _onPollFailure: function(id, o) {
        },

        _onPollComplete: function() {
            window.READY = true;
        }

    }, {

        NAME: "table",

        ATTRS: {

            id: {
                setter: parseInt
            },

            userId: {
                setter: parseInt
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
            },

            pollTimeout: {
                value: 2000,
                validator: Y.Lang.isNumber
            }

        },

        TABLE_PATH: "/ajax/tables/{{id}}.json{{#user_id}}?user_id={{user_id}}{{/user_id}}",

        TABLE_PLAYER_PATH: "/ajax/tables/{{id}}/player",

        TABLE_BIDS_PATH: "/ajax/tables/{{id}}/bids",

        TABLE_CARDS_PATH: "/ajax/tables/{{id}}/cards",

        MAIN_TEMPLATE: ''
            + '<div class="bridge-table">'
            +   '<div class="bridge-table-row-1">'
            +     '<div class="bridge-table-col-1">'
            +       '<div>&nbsp;</div>'
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
            +       '<div>&nbsp;</div>'
            +     '</div>'
            +     '<div class="bridge-table-col-2">'
            +       '<div class="bridge-hand-s"></div>'
            +     '</div>'
            +     '<div class="bridge-table-col-3">'
            +       '<div class="bridge-biddingbox"></div>'
            +     '</div>'
            +   '</div>'
            + '</div>'

    });

    Y.Bridge.Table = Table;

}, "0", { requires: ["base", "node", "gallery-io-poller", "json", "mustache", "hand", "biddingbox", "auction", "trick"] });
