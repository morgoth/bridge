YUI.add("table-model", function (Y) {

    var Table = Y.Base.create("table-model", Y.Model, [], {

        initializer: function () {
            this._board = new Y.Bridge.Model.Board();
            this._board.parent = this;
            this._board.addTarget(this);

            this._playerList = new Y.Bridge.Model.PlayerList();
            this._playerList.parent = this;
            this._playerList.addTarget(this);

            // this._refreshBoard(this.get("board"));
            // this._refreshBoard(this.get("players"));
        },

        _refreshBoard: function (board) {
            this._board.setAttrs(board);
        },

        _refreshPlayers: function (players) {
            this._playerList.refresh(players);
        },

        sync: function (action, options, callback) {
            switch (action) {
            case "create":

                break;
            case "update":

                break;
            case "read":
                Y.io("/ajax/tables/" + this.get("id") + ".json", {
                    on: {
                        success: function (transactionId, response) {
                            callback(null, response.responseText);
                        },
                        failure: function (transactionId, response) {
                            callback(response.statusText, response.responseText);
                        }
                    }
                });
                break;
            case "delete":

                break;
            }
        }

    }, {

        ATTRS: {

            state: {

            }

        }

    });

    Y.namespace("Bridge.Model").Table = Table;

}, "", { requires: ["model", "board-model", "player-model-list", "io"] });
