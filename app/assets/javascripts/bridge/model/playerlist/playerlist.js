YUI.add("player-model-list", function (Y) {

    var PlayerList = Y.Base.create("player-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Player

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").PlayerList = PlayerList;

}, "", { requires: ["model-list", "player-model"] });
