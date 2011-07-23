YUI.add("tricks", function (Y) {

    var Tricks = Y.Base.create("tricks", Y.Widget, [Y.WidgetParent], {

        TRICKS_NUM: 13,
        CONTENT_TEMPLATE: '<div>' +
            '<div class="scores">' +
            '<div class="NS"></div><div class="WE"></div>' +
            '</div>' +
            '<ul class="children"></ul>' +
            '</div>',

        addTrick: function (trick) {
            var i = this.get("current"),
                winner = trick.get("winner"),
                side = (winner === "N" || winner === "S" ? "NS" : "WE"),
                won = Y.Bridge.areSameSide(this.get("player"), winner);

            this._set("current", i + 1);
            // Save trick
            this.item(i).set("won", won);
            // Increment scores
            this.set("scores" + side, this.get("scores" + side) + 1);
        },

        renderUI: function () {
            this._renderTricks();
        },

        _renderTricks: function () {
            var cb = this.get("contentBox"),
                scoresNode = cb.one(".scores"),
                childrensNode = cb.one(".children");

            // scores
            this._scoresNodeNS = scoresNode.one(".NS");
            this._scoresNodeWE = scoresNode.one(".WE");
            // tricks
            for (var i = 0; i < this.TRICKS_NUM; i++) {
                this.add({ won: undefined, boundingBox: childrensNode });
            }
        },

        bindUI: function () {
            this.after("tricksChange", this._afterTricksChange);
            this.after("playerChange", this._afterPlayerChange);
            this.after("scoresWEChange", this._afterScoresWEChange);
            this.after("scoresNSChange", this._afterScoresNSChange);
        },

        _afterTricksChange: function (event) {
            this._syncTricks(event.newVal);
        },

        _afterPlayerChange: function (event) {
            this._syncPlayer(event.newVal);
        },

        _afterScoresNSChange: function (event) {
            this._syncScoresNS(event.newVal);
        },

        _afterScoresWEChange: function (event) {
            this._syncScoresWE(event.newVal);
        },

        syncUI: function () {
            this._syncTricks(this.get("tricks"));
            this._syncScoresNS(this.get("scoresNS"));
            this._syncScoresWE(this.get("scoresWE"));
        },

        _syncTricks: function (tricks) {
            this._clear();
            Y.each(tricks, function (trick) {
                this.addTrick(trick);
            }, this);
        },

        _syncPlayer: function (player) {
            this._syncTricks(this.get("tricks"));
        },

        _syncScoresNS: function (scores) {
            this._scoresNodeNS.set("innerHTML", scores);
        },

        _syncScoresWE: function (scores) {
            this._scoresNodeWE.set("innerHTML", scores);
        },

        _clear: function () {
            // hide children
            this.each(function (child) {
                child.set("won", undefined);
            }, this);
            // reset attributes
            this._set("current", 0);
            this.set("scoresNS", 0);
            this.set("scoresWE", 0);
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

            // Current trick number
            current: {
                value: 0,
                validator: Y.Bridge.isNumber,
                readOnly: true
            },

            // Used to resync widget with some state. To add single trick use addTrick.
            tricks: {
                value: [],
                validator: Y.Lang.isArray
            },

            scoresNS: {
                value: 0,
                validator: Y.Lang.isNumber
            },

            scoresWE: {
                value: 0,
                validator: Y.Lang.isNumber
            }
        }

    });

    Y.namespace("Bridge").Tricks = Tricks;

}, "0", { requires: ["trickstrick", "widget-parent", "helpers"] });
