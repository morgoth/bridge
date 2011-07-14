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
                    this.add(this._cards.item(position).setAttrs({ card: cards[i], visible: true }), i);
                } else {
                    cards[position].hide();
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
                setter: Y.Bridge.isDirection
            },

            bottom: {
                value: "S",
                setter: Y.Bridge.isDirection
            },

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge").Trick = Trick;

}, "0", { requires: ["widget", "widget-parent", "trickcard", "helpers"] });
