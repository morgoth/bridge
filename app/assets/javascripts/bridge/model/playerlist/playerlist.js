YUI.add("player-model-list", function (Y) {

    var PlayerList = Y.Base.create("player-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Player,

        isCompleted: function () {
            return this.size() === 4;
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").PlayerList = PlayerList;

}, "", { requires: ["model-list", "player-model"] });
