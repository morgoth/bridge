YUI.add("player-model-list", function (Y) {

    var PlayerList = Y.Base.create("player-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Player,

        table: function () {
            return this._table;
        },

        getByDirection: function (direction) {
            return Y.Array.find(this._items, function (player) {
                return player.get("direction") === direction;
            });
        },

        isCompleted: function () {
            return this.size() === 4;
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").PlayerList = PlayerList;

}, "", { requires: ["model-list", "player-model"] });
