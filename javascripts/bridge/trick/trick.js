YUI.add("trick", function (Y) {

    var Trick = Y.Base.create("trick", Y.Widget, [], {

        CONTENT_TEMPLATE: '<ul></ul>',

        renderUI: function () {

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
                var direction = Y.Bridge.DIRECTIONS[(i +  Y.Bridge.directionDistance(this.get("rotation"), this.get("lead")) + 2) % 4]; // TODO: test

                child.get("boundingBox").addClass(this.getClassName("card", direction.toLowerCase()));
            }, this);
        },

        _setRotation: function (rotation) {
            return Y.Bridge.isRotation(rotation) ? rotation : "S";
        }

    }, {

        ATTRS: {

            lead: {
                value: "N"
            },

            cards: {
                value: []
            },

            rotation: {
                setter: "_setRotation",
                value: "S"
            }

        }

    });

    Y.namespace("Bridge").Trick = Trick;

}, "0", { requires: ["cardlist", "helpers"] });
