YUI.add("table-model", function (Y) {

    var Table = Y.Base.create("table-model", Y.Model, [], {

        initializer: function () {
            this._board = new Y.Bridge.Model.Board();
            this._board.parent = this;
            this._board.addTarget(this);

            this._playerList = new Y.Bridge.Model.PlayerList();
            this._playerList.parent = this;
            this._playerList.addTarget(this);

            this.after("playersChange", this._afterPlayersChange);
            this.after("boardChange", this._afterBoardChange);
        },

        _afterPlayersChange: function (event) {
            this._refreshPlayers(event.newVal);
        },

        _afterBoardChange: function (event) {
            this._refreshBoard(event.newVal);
        },

        _refreshPlayers: function (players) {
            this._playerList.refresh(players);
        },

        _refreshBoard: function (board) {
            this._board.setAttrs(board);
        },

        _url: function (id) {
            id || (id = this.get("id"));

            if (id) {
                return "/ajax/tables/" + id + ".json";
            } else {
                return "/ajax/tables.json";
            }
        },

        sync: function (action, options, callback) {
            options || (options = {});

            var configuration = {
                    on: {
                        success: function (transactionId, response) {
                            callback(null, response.responseText);
                        },
                        failure: function (transactionId, response) {
                            callback(response.statusText, response.responseText);
                        }
                    }
                };

            switch (action) {
            case "create":
                configuration.method = "POST";
                break;
            case "update":
                configuration.method = "PUT";
                break;
            case "read":
                configuration.method = "GET";
                break;
            case "delete":
                configuration.method = "DELETE";
                break;
            }

            Y.io(this._url(options.id), configuration);
        }

    }, {

        ATTRS: {

            players: {
                value: []
            }

        }

    });

    Y.namespace("Bridge.Model").Table = Table;

}, "", { requires: ["model", "board-model", "player-model-list", "io"] });
