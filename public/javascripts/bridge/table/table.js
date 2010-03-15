YUI.add("table", function(Y) {

    Y.namespace("Bridge");

    function Table() {
        Table.superclass.constructor.apply(this, arguments);
    };

    Y.extend(Table, Y.Base, {

        initializer: function() {
            var id = this.get("id"),
                container = this.get("container");

            if(container && id) {
                this._renderUI();
                this._bindUI();
                this._initializePoll();
                this.poll.start();
            }
        },

        _renderUI: function() {
            this._renderTable();
            this._renderHands();
        },

        _bindUI: function() {
            this.on("hand:join", this._onHandJoin);
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

        _initializePoll: function() {
            var timeout = this.get("pollTimeout"),
                tablePath = Y.mustache(Table.TABLE_PATH, {
                    id: this.get("id")
                });

            this.poll = Y.io.poll(timeout, tablePath, {
                on: {
                    modified: this._onPollModified
                }
            });
        },

        _onPollModified: function(id, o) {
            var tableData = Y.JSON.parse(o.responseText);
        }

    }, {

        NAME: "table",

        ATTRS: {

            id: {
                readOnly: true,
                getter: function() {
                    var container = this.get("container");

                    return parseInt(container && container.getAttribute("data-table-id"));
                }
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
