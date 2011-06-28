YUI.add("card-list", function (Y) {

    var CardList = Y.Base.create("cardlist", Y.Widget, [Y.WidgetParent], {

        renderUI: function () {
            this._renderChildrenContainer();
        },

        _renderChildrenContainer: function () {
            this._childrenContainer = this.get("contentBox").appendChild('<ul>').addClass(this.getClassName("cards"));
        },

        bindUI: function () {
            this.after("cardsChange", this._afterCardsChange);
            this.after("disabledChange", this._afterDisabledChange);
        },

        syncUI: function () {
            this._uiSyncCards(this.get("cards"));
            this._uiSyncDisabled(this.get("disabled"));
        },

        _uiSyncCards: function (cards) {
            while (this._items.length) {
                this._items[0].destroy();
            }

            Y.each(cards, function (card, i) {
                this.add(new Y.Bridge.Card({ card: card, disabled: true, visible: true }));
            }, this);
        },

        _uiSyncDisabled: function (disabled) {
            this.each(function (child) {
                child.set("disabled", disabled);
            });
        },

        _afterCardsChange: function (event) {
            this._uiSyncCards(event.newVal);
            this._uiSyncDisabled(this.get("disabled"));
        },

        _afterDisabledChange: function (event) {
            this._uiSyncDisabled(event.newVal);
        }

    }, {

        ATTRS: {

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge").CardList = CardList;

}, "0", { requires: ["widget", "widget-parent", "card"] });
