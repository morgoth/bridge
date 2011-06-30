YUI.add("hand", function (Y) {

    var Hand = Y.Base.create("hand", Y.Widget, [], {

        renderUI: function () {
            this._renderCardList();
            this._renderHandBar();
        },

        _renderCardList: function () {
            this._cardList = new Y.Bridge.CardList().render(this.get("contentBox"));
        },

        _renderHandBar: function () {
            this._handBar = new Y.Bridge.HandBar().render(this.get("contentBox"));
        },

        bindUI: function () {

        },

        syncUI: function () {
            this._cardList.set("cards", this.get("cards"));
        }

    }, {

        ATTRS: {

            cards: {
                value: [],
                validator: Y.Lang.isArray
            }

        }

    });

    Y.namespace("Bridge").Hand = Hand;

}, "", { requires: ["cardlist", "handbar"] });
