YUI.add("player-model", function (Y) {

    var Player = Y.Base.create("player", Y.Model, [], {

    }, {

        ATTRS: {

            name: {

            },

            direction: {

            }

        }

    });

    Y.namespace("Bridge.Model").Player = Player;

}, "", { requires: ["model"] });
