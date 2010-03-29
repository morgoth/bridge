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
            var html, cardNodes, playerPosition, leadPosition, positionDistance,
                player = this.get("player") || "S",
                lead =  this.get("lead"),
                contentBox = this.get("contentBox");
            positionDistance = Y.Bridge.directionDistance(player, lead);
            cardNodes = contentBox.all("." + this.getClassName("direction"));
            cardNodes.set("innerHTML", "");
            cardNodes.removeClass("card", "1");
            cardNodes.removeClass("card", "2");
            cardNodes.removeClass("card", "3");
            cardNodes.removeClass("card", "4");

            if(cards) {
                Y.each(cards, function(card, i) {
                    var html,
                        position = (i + 2 + positionDistance) % 4, // TODO: test me please!
                        cardNumber = i + 1,
                        classNames = [
                            this.getClassName("card"),
                            this.getClassName("card", card.toLowerCase())
                        ];
                    html = Y.mustache(Trick.CARD_TEMPLATE, {
                        classNames: classNames.join(" ")
                    });

                    cardNodes.item(position).set("innerHTML", html).addClass(this.getClassName("card", cardNumber));
                }, this);
            }
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
            +   '{{#directions}}'
            +     '<li class="{{classNames}}"></li>'
            +   '{{/directions}}'
            + '</ul>',

        CARD_TEMPLATE: ''
            + '<div class="{{classNames}}"></div>'

    });

    Y.Bridge.Trick = Trick;

}, "0", { requires: ["widget"] });

