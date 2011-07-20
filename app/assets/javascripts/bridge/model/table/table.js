YUI.add("table-model", function (Y) {

    var Table = Y.Base.create("table-model", Y.Model, [], {

        initializer: function () {
            this._board = new Y.Bridge.Model.Board();
            this._board.addTarget(this);

            this._playerList = new Y.Bridge.Model.PlayerList();
            this._playerList.addTarget(this);

            // this._refreshBoard(this.get("board"));
            // this._refreshBoard(this.get("players"));
        },

        _refreshBoard: function (board) {
            this._board.setAttrs(board);
        },

        _refreshPlayers: function (players) {
            this._playerList.refresh(players);
        }

    }, {

        ATTRS: {

            state: {

            }

        }

    });

    Y.namespace("Bridge.Model").Table = Table;

}, "", { requires: ["model", "board-model", "player-model-list"] });
