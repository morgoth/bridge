YUI.add("handcards", function (Y) {

    var HandCards = Y.Base.create("handcards", Y.Widget, [Y.WidgetParent], {

        CONTENT_TEMPLATE : '<ul></ul>',

        renderUI: function () {
            this._renderCards();
        },

        _renderCards: function () {
            for (var i = 0; i < this.get("size"); i++) {
                this.add({ disabled: this.get("disabled"), visible: true });
            }
        },

        bindUI: function () {
            this.after("cardsChange", this._afterCardsChange);
            this.after("disabledChange", this._afterDisabledChange);
        },

        syncUI: function () {
            this._syncCards(this.get("cards"));
            this._syncDisabled(this.get("disabled"));
        },

        _syncCards: function (cards) {
            var disabled = this.get("disabled");

            this.each(function (card, i) {
                if (Y.Lang.isValue(cards[i])) {
                    card.setAttrs({ card: cards[i], disabled: disabled }).show();
                } else {
                    card.hide();
                }
            });
        },

        _syncDisabled: function (disabled) {
            this.each(function (card) {
                card.set("disabled", disabled);
            });
        },

        _afterCardsChange: function (event) {
            this._syncCards(event.newVal);
        },

        _afterDisabledChange: function (event) {
            this._syncDisabled(event.newVal);
        },

        _validateSize: function (size) {
            return Y.Lang.isNumber(size) && size > 0;
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.Bridge.Card
            },

            size: {
                value: 13,
                validator: "_validateSize",
                writeOnce: "initOnly"
            },

            disabled: {
                value: true
            },

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge").HandCards = HandCards;

}, "", { requires: ["widget", "widget-parent", "card"] });
