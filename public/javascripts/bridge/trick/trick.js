YUI.add("trick", function(Y) {

    Y.namespace("Bridge");

    function Trick() {
        Trick.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Trick, Y.Widget, {

        renderUI: function() {
            this._renderTrick();
        },

        bindUI: function() {
            this.after("cardsChange", this._afterCardsChange);
            this.after("playerChange", this._afterPlayerChange);
        },

        syncUI: function() {
            this._uiSetCards(this.get("cards"));
        },

        _afterCardsChange: function(event) {
            this._uiSetCards(event.newVal);
        },

        _afterPlayerChange: function(event) {
            this._uiSetPlayer(event.newVal);
        },

        _renderTrick: function() {
            var html, directions,
                contentBox = this.get("contentBox");
            directions = Y.Array.map(Y.Bridge.DIRECTIONS, function(direction) {
                var classNames = [
                    this.getClassName("direction"),
                    this.getClassName("direction", direction.toLowerCase())
                ];

                return {
                    classNames: classNames.join(" ")
                };
            }, this);
            html = Y.mustache(Trick.TRICK_TEMPLATE, {
                cardsCN: this.getClassName("cards"),
                directions: directions
            });

            contentBox.set("innerHTML", html);
        },

        _uiSetPlayer: function(player) {
            this._uiSetCards(this.get("cards"));
        },

        _uiSetCards: function(cards) {
            var html, cardsNode, playerPosition, leadPosition, positionDistance, cardsData,
                player = this.get("player"),
                lead =  this.get("lead"),
                contentBox = this.get("contentBox");
            positionDistance = Y.Bridge.directionDistance(player, lead);
            cardsNode = contentBox.one("." + this.getClassName("cards"));

            if(cards) {
                cardsData = Y.Array.map(cards, function(card, i) {
                    var position = (i +  positionDistance + 2) % 4, // TODO: test me please!
                        classNames = [
                            this.getClassName("card"),
                            this.getClassName("card", card.toLowerCase()),
                            this.getClassName("card", Y.Bridge.DIRECTIONS[position].toLowerCase())
                        ];

                    return {
                        classNames: classNames.join(" ")
                    };
                }, this);

                html = Y.mustache(Trick.CARDS_TEMPLATE, {
                    cards: cardsData
                });
            }

            cardsNode.set("innerHTML", html || "");
        }
    }, {

        NAME: "trick",

        ATTRS: {

            lead: {
                validator: Y.Bridge.isDirection,
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
            }

        },

        TRICK_TEMPLATE: ''
            + '<ul class="{{cardsCN}}">'
            + '</ul>',

        CARDS_TEMPLATE: ''
            + '{{#cards}}'
            +   '<li class="{{classNames}}"></li>'
            + '{{/cards}}'

    });

    Y.Bridge.Trick = Trick;

}, "0", { requires: ["widget"] });
