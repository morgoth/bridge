YUI.add("table-model", function (Y) {

    var Table = Y.Base.create("table-model", Y.Model, [], {

        initializer: function () {
            this._board = new Y.Bridge.Model.Board();
            this._board.addTarget(this);

            this._playerList = new Y.Bridge.Model.PlayerList();
            this._playerList.addTarget(this);

            this.after("boardChange", this._afterBoardChange);
            this.after("playersChange", this._afterBoardChange);

            this._refreshBoard(this.get("board"));
            this._refreshBoard(this.get("players"));
        },

        _afterBoardChange: function (event) {
            this._refreshBoard(event.newVal);
        },

        _afterPlayersChange: function (event) {
            this._refreshPlayers(event.newVal);
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

            },

            players: {

            },

            board: {

            }

        }

    });

    Y.namespace("Bridge.Model").Table = Table;

}, "", { requires: ["model", "board-model", "player-model-list"] });
