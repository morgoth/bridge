YUI.add("card-model-list", function (Y) {

    var CardList = Y.Base.create("card-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Card,

        getCards: function () {
            return Y.Array.map(this._items, function (card) {
                return card.get("card");
            });
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").CardList = CardList;

}, "", { requires: ["model-list", "card-model"] });
