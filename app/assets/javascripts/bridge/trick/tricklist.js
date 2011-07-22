YUI.add("tricklist", function (Y) {

    var TrickList = Y.Base.create("trickList", Y.Widget, [], {
        
        TRICKS_NUM: 13,
        SCORES_TEMPLATE: '<div class="scores"><div class="NS"></div><div class="WE"></div></div>',
        TRICKLIST_TEMPLATE: '<ul class="tricks"></ul>',
        TRICK_TEMPLATE: '<li class="trick"></li>',
        
        addTrick: function (trick) {
            // TODO: winner is not yet an trick's attr
            var i = this.get("current"),
                winner = trick.get("winner"),
                side = (winner === "N" || winner === "S" ? "NS" : "WE"),
                won = Y.Bridge.areSameSide(this.get("player"), winner);

            // Save trick
            this._set("current", i + 1);
            this._tricks[i] = trick;
            this._trickNodes[i].addClass(won ? "won" : "lost").show();
            // Increment scores
            this.set("scores" + side, this.get("scores" + side) + 1);
        },

        clear: function () {
            Y.each(this._trickNodes, function (node) {
                node.hide().removeClass("lost").removeClass("won");
            });
            this._tricks = [];
            this._set("current", 0);
            this.set("scoresNS", 0);
            this.set("scoresWE", 0);
        },

        renderUI: function () {
            this._renderTrickList();
        },

        _renderTrickList: function () {
            var cb = this.get("contentBox"),
                scoresNode = cb.appendChild(this.SCORES_TEMPLATE),
                tricksNode = cb.appendChild(this.TRICKLIST_TEMPLATE);

            // scores
            this._scoresNodeNS = scoresNode.one(".NS");
            this._scoresNodeWE = scoresNode.one(".WE");
            // tricks
            this._trickNodes = [];
            this._tricks = [];
            for (var i = 0; i < this.TRICKS_NUM; i++) {
                this._trickNodes[i] = tricksNode.appendChild(this.TRICK_TEMPLATE).hide();
            }
        },

        bindUI: function () {
            this.after("playerChange", this._afterPlayerChange);
            this.after("scoresWEChange", this._afterScoresWEChange);
            this.after("scoresNSChange", this._afterScoresNSChange);
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
            this._syncScoresNS(this.get("scoresNS"));
            this._syncScoresWE(this.get("scoresWE"));
        },

        _syncPlayer: function (player) {
            var tricks = this._tricks;

            this.set("tricks", tricks);
        },

        _syncScoresNS: function (scores) {
            this._scoresNodeNS.set("innerHTML", scores);
        },

        _syncScoresWE: function (scores) {
            this._scoresNodeWE.set("innerHTML", scores);
        },

        _getTricks: function (tricks) {
            return this._tricks;
        },
        
        _setTricks: function (tricks) {
            this.clear();
            Y.each(tricks, function (trick) {
                this.addTrick(trick);
            }, this);
        }

    }, {

        ATTRS: {

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

            // Setting this clears everything and redraws it again.
            // addTrick should be used in most cases.
            tricks: {
                value: [],
                validator: Y.Lang.isArray,
                getter: "_getTricks",
                setter: "_setTricks"
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

    Y.namespace("Bridge").TrickList = TrickList;

}, "0", { requires: ["widget", "helpers"] });
