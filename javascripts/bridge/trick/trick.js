YUI.add("trick", function (Y) {

    var Trick = Y.Base.create("trick", Y.Widget, [Y.WidgetParent], {

        CONTENT_TEMPLATE: '<ul></ul>',

        renderUI: function () {
            this._renderCards();
        },

        _renderCards: function () {
            for (var i = 0; i < 4; i++) {
                this.add({ disabled: true, visible: true });
            }
        },

        bindUI: function () {
            this.after("leadChange", this._afterLeadChange);
            this.after("rotationChange", this._afterRotationChange);
        },

        syncUI: function () {
            this._uiSyncCards(this.get("cards"));
        },

        _afterLeadChange: function (event) {
            this._uiSyncCards(this.get("cards"));
        },

        _afterRotationChange: function (event) {
            this._uiSyncCards(this.get("cards"));
        },

        _uiSyncCards: function (cards) {
            this.each(function (child, i) {
                // var direction = Y.Bridge.DIRECTIONS[(i +  Y.Bridge.directionDistance(this.get("rotation"), this.get("lead")) + 2) % 4]; // TODO: test
                var card = cards[(i +  Y.Bridge.directionDistance(this.get("rotation"), this.get("lead")) + 2) % 4];

                if (Y.Lang.isValue(card)) {
                    child.setAttrs({ card: card, visible: true });
                } else {
                    child.set("visible", false);
                }
            }, this);
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.Bridge.Card
            },

            lead: {
                validator: Y.Bridge.isDirection,
                value: "N"
            },

            cards: {
                value: []
            },

            rotation: {
                validator: Y.Bridge.isDirection,
                value: "S"
            }

        }

    });

    Y.namespace("Bridge").Trick = Trick;

}, "0", { requires: ["widget", "widget-parent", "card", "helpers"] });
