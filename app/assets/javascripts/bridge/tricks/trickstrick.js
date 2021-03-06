YUI.add("trickstrick", function (Y) {

    var TricksTrick = Y.Base.create("trickstrick", Y.Widget, [Y.WidgetChild], {
        BOUNDING_TEMPLATE: '<li></li>',

        renderUI: function () {
            this.get("contentBox").appendChild("<div></div>").addClass(
                this.getClassName("cover"));
        },

        bindUI: function () {
            this.after("wonChange", this._afterWonChange);
        },

        _afterWonChange: function (event) {
            this._syncWon(event.newVal);
        },

        syncUI: function () {
            this._syncWon(this.get("won"));
        },

        _syncWon: function (won) {
            var cb = this.get("contentBox"),
                c_won = this.getClassName("won"),
                c_lost = this.getClassName("lost");

            if (won) {
                cb.removeClass(c_lost).addClass(c_won);
            } else {
                cb.removeClass(c_won).addClass(c_lost);
            }
        }

    }, {

        ATTRS: {

            won: {
                value: false,
                validator: Y.Lang.isBoolean
            }
            // TODO: Add later: winner, lead, cards (like trick/trick.js)
        }

    });
    Y.namespace("Bridge").TricksTrick = TricksTrick;

}, "0", { requires: ["widget", "widget-child"] });
