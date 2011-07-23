YUI.add("trickstrick", function (Y) {

    var TricksTrick = Y.Base.create("trickstrick", Y.Widget, [Y.WidgetChild], {
        CONTENT_TEMPLATE: '<li><div class="cover"></div></li>',

        renderUI: function () {

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
            var cb = this.get("contentBox");

            if (!Y.Lang.isValue(won)) {
                cb.hide();
                return;
            }
            if (won) {
                cb.removeClass("lost").addClass("won");
            } else {
                cb.removeClass("won").addClass("lost");
            }
            cb.show();
        }

    }, {

        ATTRS: {

            // If undefined - do not show
            won: {
                value: undefined,
                validator: Y.Lang.isBoolean
            }
            // TODO: Add later: winner, lead, cards (like trick/trick.js)
        }
    });
    Y.namespace("Bridge").TricksTrick = TricksTrick;

}, "0", { requires: ["widget", "widget-child"] });
