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
        },

        _bindUI: function() {
            this.on("hand:join", this._onHandJoin);
            this.on("hand:quit", this._onHandQuit);
            this.on("hand:card", this._onHandCard);
            this.on("biddingbox:bid", function(event) {
                Y.log(event[0]);
            });
            this.after("tableDataChange", this._afterTableDataChange);
        },

        _onHandJoin: function(event) {
            var direction = event.target.get("direction");

            this._io(this._tablePlayerPath(), { method: "POST", data: "player[direction]=" + direction });
        },

        _onHandQuit: function(event) {
            this._io(this._tablePlayerPath(), { method: "POST", data: "_method=DELETE" });
        },

        _onHandCard: function(event) {
            alert(event[0]);
        },

        _tablePlayerPath: function() {
            return Y.mustache(Table.TABLE_PLAYER_PATH, {
                id: this.get("id")
            });
        },

        _io: function(uri, configuration) {
            configuration = configuration || {};
            configuration.on = configuration.on || {};
            configuration.on.success = Y.bind(this._onRequestSuccess, this);
            configuration.on.failure = Y.bind(this._onRequestFailure, this);

            this.poll.stop();
            Y.io(uri, configuration);
        },

        _afterTableDataChange: function(event) {
            this._uiSyncTable(event.newVal);
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

            this.biddingBox = new Y.Bridge.BiddingBox({ host: this, boundingBox: biddingBoxNode });
            this.biddingBox.render();
        },

        _renderAuction: function() {
            var auctionNode, auction,
                container = this.get("container");

            auctionNode = container.one(".bridge-auction");

            auction = new Y.Bridge.Auction({ host: this, boundingBox: container });
            auction.render();
        },

        _uiSyncTable: function(tableData) {
            this._uiSyncHands(tableData.hands);
            // this.biddingBox.setAttrs(tableData.biddingBox);
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
                    modified: Y.bind(this._onPollModified, this)
                }
            });
        },

        _onPollModified: function(id, o) {
            var tableData = Y.JSON.parse(o.responseText);

            this.set("tableData", tableData);
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

            tableData: {
            },

            state: {
                value: "preparing"
            },

            container: {
                value: "body",
                setter: function(selector) {
                    return Y.one(selector);
                }
            },

            pollTimeout: {
                value: 10000,
                validator: Y.Lang.isNumber
            }

        },

        TABLE_PATH: "/ajax/tables/{{id}}.json{{#user_id}}?user_id={{user_id}}{{/user_id}}",

        TABLE_PLAYER_PATH: "/ajax/tables/{{id}}/player",

        DIRECTIONS: ["N", "E", "S", "W"],

        MAIN_TEMPLATE: '' +
            '<div class="bridge-table">' +
              '<h3>Bridge Libre!</h3>' +
              '<div class="bridge-hand-n"></div>' +
              '<div class="bridge-hand-e"></div>' +
              '<div class="bridge-hand-s"></div>' +
              '<div class="bridge-hand-w"></div>' +
              '<div class="bridge-biddingbox"></div>' +
              '<div class="bridge-auction"></div>' +
            '</div>'

    });

    Y.Bridge.Table = Table;

}, "0", { requires: ["base", "node", "gallery-io-poller", "json", "mustache", "hand", "biddingbox", "auction"] });
