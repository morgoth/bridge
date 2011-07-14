YUI.add("trick", function (Y) {

    var Trick = Y.Base.create("trick", Y.Widget, [Y.WidgetParent], {

        CONTENT_TEMPLATE: '<ul></ul>',

        renderUI: function () {
            this._renderCards();
        },

        _renderCards: function () {
            this._cards = this.add([
                { position: "top" },
                { position: "right" },
                { position: "bottom" },
                { position: "left" }
            ]);
        },

        bindUI: function () {
            this.after("leadChange", this._afterLeadChange);
            this.after("bottomChange", this._afterBottomChange);
            this.after("cardsChange", this._afterCardsChange);
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

        _afterCardsChange: function (event) {
            this._uiSyncCards(event.newVal);
        },

        _uiSyncCards: function (cards) {
            var position, i;

            for (position = 0; position < 4; position++) {
                i = (Y.Bridge.directionDistance(this.get("bottom"), this.get("lead")) + position + 2) % 4; // pure magic

                if (cards[position]) {
                    this.add(this._cards.item(i).setAttrs({ card: cards[position], visible: true }), position);
                } else {
                    this.add(this._cards.item(i).setAttrs({ card: "", visible: false }), position);
                }
            }
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.Bridge.TrickCard
            },

            lead: {
                value: "N",
                validator: Y.Bridge.isDirection
            },

            bottom: {
                value: "S",
                validator: Y.Bridge.isDirection
            },

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge").Trick = Trick;

}, "0", { requires: ["widget", "widget-parent", "trickcard", "helpers"] });
