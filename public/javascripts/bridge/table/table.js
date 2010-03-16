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
        },

        _bindUI: function() {
            this.on("hand:join", this._onHandJoin);
            this.on("hand:quit", this._onHandQuit);
            this.after("tableDataChange", this._afterTableDataChange);
        },

        _onHandJoin: function(event) {
            var direction = event.target.get("direction"),
                tablePlayerPath = Y.mustache(Table.TABLE_PLAYER_PATH, {
                    id: this.get("id")
                });

            this.poll.stop();
            Y.io(tablePlayerPath, {
                method: "POST",
                data: "player[direction]=" + direction,
                on: {
                    success: Y.bind(this._onRequestSuccess, this),
                    failure: Y.bind(this._onRequestFailure, this)
                }
            });
        },

        _onHandQuit: function(event) {
            var tablePlayerPath = Y.mustache(Table.TABLE_PLAYER_PATH, {
                    id: this.get("id")
                });

            this.poll.stop();
            Y.io(tablePlayerPath, {
                method: "POST",
                data: "&_method=DELETE",
                on: {
                    success: Y.bind(this._onRequestSuccess, this),
                    failure: Y.bind(this._onRequestFailure, this)
                }
            });
        },

        _afterTableDataChange: function(event) {
            this._uiSyncTable(event.newVal);
        },

        _onRequestSuccess: function() {
            this.poll.start();
        },

        _onRequestFailure: function(id, response) {
            Y.log(response);
        },

        _renderTable: function() {
            var container = this.get("container");

            container.set("innerHTML", "Bridge Libre!");
        },

        _renderHands: function() {
            this.hands = {};

            Y.each(Table.DIRECTIONS, function(direction) {
                var hand = new Y.Bridge.Hand({ host: this, direction: direction });

                this.hands[direction] = hand;
                hand.render();
            }, this);
        },

        _uiSyncTable: function(tableData) {
            this._uiSyncHands(tableData);
        },

        _uiSyncHands: function(tableData) {
            var userId = this.get("userId"),
                playerDirection = tableData.player,
                players = tableData.players;

            Y.each(this.hands, function(hand, direction) {
                hand.set("joinEnabled", !!(userId && !playerDirection));
                hand.set("quitEnabled", !!(userId && (playerDirection === direction)));
                hand.set("name", players[direction] && players[direction].name);
            }, this);
        },

        _initializePoll: function() {
            var timeout = this.get("pollTimeout"),
                tablePath = Y.mustache(Table.TABLE_PATH, {
                    id: this.get("id")
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

            container: {
                value: "body",
                setter: function(selector) {
                    return Y.one(selector);
                }
            },

            pollTimeout: {
                value: 3000,
                validator: Y.Lang.isNumber
            }

        },

        TABLE_PATH: "/ajax/tables/{{id}}.json",

        TABLE_PLAYER_PATH: "/ajax/tables/{{id}}/player",

        DIRECTIONS: ["N", "E", "S", "W"]

    });

    Y.Bridge.Table = Table;

}, "0", { requires: ["base", "node", "gallery-io-poller", "json", "mustache", "hand"] });
