YUI.add("card-model", function (Y) {

    var Card = Y.Base.create("card-model", Y.Model, [], {

    }, {

        ATTRS: {

            card: {

            }

        }

    });

    Y.namespace("Bridge.Model").Card = Card;

}, "", { requires: ["model"] });
