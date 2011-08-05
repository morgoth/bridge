YUI.add("card-model-list", function (Y) {

    var CardList = Y.Base.create("card-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Card,

        board: function () {
            return this._board;
        },

        isCompleted: function () {
            return this.size() === 52;
        },

        cards: function () {
            return Y.Array.map(this._items, function (card) {
                return card.get("card");
            });
        },

        trick: function (number) {
            var start = number * 4;

            return this._items.slice(start, start + 4);
        },

        currentTrickNumber: function () {
            return Math.floor(this.size() / 4);
        },

        currentTrick: function () {
            return this.trick(this.currentTrickNumber());
        },

        previousTrickNumber: function () {
            var result = Math.floor(this.size() - 4 / 4);

            return result < 0 ? undefined : result;
        },

        previousTrick: function () {
            return Y.Lang.isValue(this.previousTrickNumber()) ? this.trick(this.previousTrickNumber()) : undefined;
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").CardList = CardList;

}, "", { requires: ["model-list", "card-model", "collection"] });
