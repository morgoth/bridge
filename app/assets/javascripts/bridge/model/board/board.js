YUI.add("board-model", function (Y) {

    var Board = Y.Base.create("board-model", Y.Model, [], {

    }, {

        ATTRS: {

            deal: {
                value: {
                    "N": ["", "", "", "", "", "", "", "", "", "", "", "", ""],
                    "E": ["", "", "", "", "", "", "", "", "", "", "", "", ""],
                    "S": ["", "", "", "", "", "", "", "", "", "", "", "", ""],
                    "W": ["", "", "", "", "", "", "", "", "", "", "", "", ""]
                }
            },

            dealer: {

            },

            vulnerable: {

            },

            declarer: {
                value: null
            },

            contract: {
                value: null
            },

            bids: {
                value: []
            },

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge.Model").Board = Board;

}, "", { requires: ["model"] });
