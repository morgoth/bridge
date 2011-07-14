YUI.add("trickcard", function (Y) {

    var TrickCard = Y.Base.create("trickcard", Y.Bridge.Card, [], {

        syncUI: function () {
            this.constructor.superclass.syncUI.apply(this, arguments);
            this.get("boundingBox").addClass(this.getClassName(this.get("position")));
        }

    }, {

        CSS_PREFIX: "yui3-card",

        ATTRS: {

            position: {
                writeOnce: "initOnly"
            },

            disabled: {
                value: true
            }

        }

    });

    Y.namespace("Bridge").TrickCard = TrickCard;

}, "0", { requires: ["card"] });
