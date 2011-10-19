YUI.add("table-model", function (Y) {

    var Table = Y.Base.create("table", Y.Model, [Y.Bridge.Model.Sync], {

        initializer: function () {
            this._board = new Y.Bridge.Model.Board();
            this._board._table = this;
            this._board.addTarget(this);

            this._playerList = new Y.Bridge.Model.PlayerList();
            this._playerList._table = this;
            this._playerList.addTarget(this);

            this.after("playersChange", this._afterPlayersChange);
            this.after("boardChange", this._afterBoardChange);
        },

        board: function () {
            return this._board;
        },

        players: function () {
            return this._playerList;
        },

        _afterPlayersChange: function (event) {
            this._resetPlayers(event.newVal);
        },

        _afterBoardChange: function (event) {
            this._resetBoard(event.newVal);
        },

        _resetPlayers: function (players) {
            this._playerList.reset(players);
        },

        _resetBoard: function (board) {
            this._board.setAttrs(board);
        },

        _url: function (options) {
            options.id || (options.id = this.get("id"));

            if (options.id) {
                return "/ajax/tables/" + options.id + ".json";
            } else {
                return "/ajax/tables.json";
            }
        }

    }, {

        ATTRS: {

            players: {
                value: []
            },

            board: {

            }

        }

    });

    Y.namespace("Bridge.Model").Table = Table;

}, "", { requires: ["model", "board-model", "player-model-list", "sync"] });
