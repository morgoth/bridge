YUI.add("card-model", function (Y) {

    var Card = Y.Base.create("card-model", Y.Model, [], {

        suit: function () {
            return Y.Bridge.parseSuit(this.get("card"));
        },

        value: function () {
            return Y.Bridge.parseValue(this.get("card"));
        }

    }, {

        ATTRS: {

            card: {

            }

        }

    });

    Y.namespace("Bridge.Model").Card = Card;

}, "", { requires: ["model", "helpers"] });
