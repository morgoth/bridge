YUI.add("player-model-list", function (Y) {

    var PlayerList = Y.Base.create("player-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Player,

        getByDirection: function (direction) {
            return Y.Array.find(this._items, function (player) {
                return player.get("direction") === direction;
            });
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").PlayerList = PlayerList;

}, "", { requires: ["model-list", "player-model"] });
