YUI.add("player-model", function (Y) {

    var Player = Y.Base.create("player", Y.Model, [], {

        list: function () {
            return this.lists[0];
        },

        table: function () {
            return this.list() && this.list().table();
        }

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
