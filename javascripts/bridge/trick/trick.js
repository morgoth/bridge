YUI.add("trick", function (Y) {

    var Trick = Y.Base.create("trick", Y.Widget, [Y.WidgetParent], {

        CONTENT_TEMPLATE: '<ul></ul>',

        renderUI: function () {
            this._renderCards();
        },

        _renderCards: function () {
            this._cards = [];

            Y.each(["top", "right", "bottom", "left"], function (position) {
                var card = this.add({ disabled: true, visible: true }).item(0);

                this._cards.push(card);
                card.get("boundingBox").addClass(card.getClassName(position));
            }, this);
        },

        bindUI: function () {
            this.after("leadChange", this._afterLeadChange);
            this.after("bottomChange", this._afterBottomChange);
        },

        syncUI: function () {
            this._uiSyncCards(this.get("cards"));
        },

        _afterLeadChange: function (event) {
            this._uiSyncCards(this.get("cards"));
        },

        _afterBottomChange: function (event) {
            this._uiSyncCards(this.get("cards"));
        },

        _uiSyncCards: function (cards) {
            var position, i;

            for (position = 0; position < 4; position++) {
                if (cards[position]) {
                    i = (((this.get("bottom") - this.get("lead") + 4) % 4) + position + 2) % 4; // pure magic
                    this.add(this._cards[position].setAttrs({ card: cards[i], visible: true }), i);
                } else {
                    cards[position].hide();
                }
            }
        },

        _setDirection: function (direction) {
            var result = Y.Array.indexOf(["N", "E", "S", "W"], direction);

            return (result === -1) ? Y.Attribute.INVALID_VALUE : result;
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.Bridge.Card
            },

            lead: {
                value: "N",
                setter: "_setDirection"
            },

            bottom: {
                value: "S",
                setter: "_setDirection"
            },

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge").Trick = Trick;

}, "0", { requires: ["widget", "widget-parent", "card"] });
