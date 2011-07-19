YUI.add("card-model-list", function (Y) {

    var CardList = Y.Base.create("card-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Card

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").CardList = CardList;

}, "", { requires: ["model-list", "card-model"] });
