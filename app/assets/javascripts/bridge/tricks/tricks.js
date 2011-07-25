YUI.add("tricks", function (Y) {

    var Tricks = Y.Base.create("tricks", Y.Widget, [], {

        TRICKS_NUM: 13,
        renderUI: function () {
            this._renderTricks();
        },

        _renderTricks: function () {
            var cb = this.get("contentBox"),
            // Generating nodes
                tricksBarNode = cb.appendChild("<div></div>"),
                infoNode = cb.appendChild("<div></div>").addClass(
                    this.getClassName("info")),
                scoresNode = infoNode.appendChild("<div></div>").addClass(
                   this.getClassName("scores"));

            this._scoresNodeWE = scoresNode.appendChild("<div></div>").addClass(
                this.getClassName("scores", "NS"));
            this._scoresNodeNS = scoresNode.appendChild("<div></div>").addClass(
                this.getClassName("scores", "WE"));

            this._tricksBar = new Y.Bridge.TricksBar({
                player: this.get("player"),
                tricks: this.get("tricks")
            }).render({ boudningBox: tricksBarNode });

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
            this._syncPlayer(this.get("player"));
            this._syncScoresNS(this.get("scoresNS"));
            this._syncScoresWE(this.get("scoresWE"));
        },

        _syncTricks: function (tricks) {
            // Recalculate scores
            var scores = { NS: 0, WE: 0 };

            Y.each(tricks, function (trick) {
                var winner = trick.get("winner"),
                    side = (winner === "N" || winner === "S" ? "NS" : "WE"),
                    won = Y.Bridge.areSameSide(this.get("player"), winner);
                    scores[side] += 1;
            }, this);
            this.set("scoresWE", scores.WE);
            this.set("scoresNS", scores.NS);
            // Sync tricksBar
            this._tricksBar.set("tricks", tricks);
        },

        _syncPlayer: function (player) {
            this._syncTricks(this.get("tricks"));
            this._tricksBar.set("player", player);
        },

        _syncScoresNS: function (scores) {
            this._scoresNodeNS.set("innerHTML", scores);
        },

        _syncScoresWE: function (scores) {
            this._scoresNodeWE.set("innerHTML", scores);
        }

    }, {

        ATTRS: {

            player: {
                value: "N",
                validator: Y.Bridge.isDirection
            },

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

}, "0", { requires: ["tricksbar", "helpers"] });
