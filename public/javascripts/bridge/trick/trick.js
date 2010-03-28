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
        },

        syncUI: function() {
            this._uiSetCards(this.get("cards"));
        },

        _afterCardsChange: function(event) {
            this._uiSetCards(event.newVal);
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

        _uiSetCards: function(cards) {
            var html, cardNodes, position,
                player = this.get("player"),
                contentBox = this.get("contentBox");
            position = Y.Bridge.dealerPosition(player);
            cardNodes = contentBox.all("." + this.getClassName("direction"));
            cardNodes.set("innerHTML", "");
            cardNodes.removeClass("card", "1");
            cardNodes.removeClass("card", "2");
            cardNodes.removeClass("card", "3");
            cardNodes.removeClass("card", "4");

            Y.log(cardNodes);

            Y.each(cards, function(card, i) {
                var html,
                    cardNumber = i + 1,
                    classNames = [
                        this.getClassName("card"),
                        this.getClassName("card", card.toLowerCase())
                    ];
                html = Y.mustache(Trick.CARD_TEMPLATE, {
                    classNames: classNames.join(" ")
                });
                cardNodes.item((i + position + 3) % 4).set("innerHTML", html).addClass(this.getClassName("card", cardNumber));
            }, this);
        }

    }, {

        NAME: "trick",

        ATTRS: {

            cards: {
                value: []
            },

            player: {
                value: "N"
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

