YUI.add("table-model", function (Y) {

    var Table = Y.Base.create("table-model", Y.Model, [], {

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

}, "", { requires: ["model"] });
