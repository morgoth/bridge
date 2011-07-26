YUI.add("tricksbar", function (Y) {

    var TricksBar = Y.Base.create("tricksbar", Y.Widget, [Y.WidgetParent], {

        CONTENT_TEMPLATE: "<ul></ul>",
        TRICKS_NUM: 13,
        renderUI: function () {
            this._renderTricksBar();
        },

        _renderTricksBar: function () {
            for (var i = 0; i < this.TRICKS_NUM; i++) {
                this.add({ });
            }
        },

        bindUI: function () {
            this.after("tricksChange", this._afterTricksChange);
            this.after("playerChange", this._afterPlayerChange);
        },

        _afterTricksChange: function (event) {
            this._syncTricks(event.newVal);
        },

        _afterPlayerChange: function (event) {
            this._syncPlayer(event.newVal);
        },

        syncUI: function () {
            this._syncTricks(this.get("tricks"));
        },

        _syncTricks: function (tricks) {
            this.each(function (trick, i) {
                if (i < tricks.length) {
                    var winner = tricks[i].get("winner"),
                        side = (winner === "N" || winner === "S" ? "NS" : "WE"),
                        won = Y.Bridge.areSameSide(this.get("player"), winner);

                    // Set trick attrs
                    trick.setAttrs({ won: won }).show();
                } else {
                    trick.hide();
                }
            }, this);
        },

        _syncPlayer: function (player) {
            this._syncTricks(this.get("tricks"));
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.Bridge.TricksTrick
            },

            player: {
                value: "N",
                validator: Y.Bridge.isDirection
            },

            tricks: {
                value: [],
                validator: Y.Lang.isArray
            }
        }

    });

    Y.namespace("Bridge").TricksBar = TricksBar;

}, "0", { requires: ["trickstrick", "widget-parent", "helpers"] });
