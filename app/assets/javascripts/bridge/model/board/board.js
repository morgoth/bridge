YUI.add("board-model", function (Y) {

    var Board = Y.Base.create("board-model", Y.Model, [], {

    }, {

        ATTRS: {

            deal: {

            },

            dealer: {

            },

            vulnerable: {

            },

            declarer: {

            },

            contract: {

            },

            bids: {

            },

            cards: {

            }

        }

    });

    Y.namespace("Bridge.Model").Board = Board;

}, "", { requires: ["model"] });
