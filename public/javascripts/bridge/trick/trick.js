YUI.add("trick", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Trick = Y.Base.create("trick", Y.Bridge.CardList, [], {

        bindUI: function() {
            Trick.superclass.bindUI.apply(this, arguments);
            this.after("leadChange", this._afterLeadChange);
            this.after("playerChange", this._afterPlayerChange);
        },

        syncUI: function() {
            Trick.superclass.syncUI.apply(this, arguments);
            this._uiSyncCards(this.get("cards"));
        },

        _afterLeadChange: function(event) {
            this._uiSyncCards(this.get("cards"));
        },

        _afterPlayerChange: function(event) {
            this._uiSyncCards(this.get("cards"));
        },

        _uiSyncCards: function(cards) {
            Trick.superclass._uiSyncCards.apply(this, arguments);
            this.each(function(child, i) {
                var direction = Y.Bridge.DIRECTIONS[(i +  Y.Bridge.directionDistance(this.get("player"), this.get("lead")) + 2) % 4]; // TODO: test

                child.get("boundingBox").addClass(Trick.C_CARD).addClass(Trick["C_CARD_" + direction]);
            }, this);
        }

    }, {

        NAME: "trick",

        ATTRS: {

            lead: {
                value: "N"
            },

            cards: {
                value: []
            },

            player: {
                setter: function(player) {
                    return Y.Bridge.isDirection(player) ? player : "S";
                },
                value: "S"
            },

            disabled: {
                value: true
            }

        },

        C_CARD: getClassName("trick", "card"),
        C_CARD_N: getClassName("trick", "card", "n"),
        C_CARD_E: getClassName("trick", "card", "e"),
        C_CARD_S: getClassName("trick", "card", "s"),
        C_CARD_W: getClassName("trick", "card", "w")

    });

    Y.Bridge.Trick = Trick;

}, "0", { requires: ["cardlist", "helpers"] });
