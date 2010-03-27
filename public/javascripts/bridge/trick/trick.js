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
            var html,
                contentBox = this.get("contentBox");
            html = Y.mustache(Trick.TRICK_TEMPLATE, {
                cardsCN: this.getClassName("cards")
            });

            contentBox.set("innerHTML", html);
        },

        _uiSetCards: function(cards) {
            var html, cardsNode, cardsData,
                contentBox = this.get("contentBox");
            cardsNode = contentBox.one("." + this.getClassName("cards"));
            cardsData = Y.Array.map(cards, function(card) {
                var classNames = [
                    this.getClassName("card"),
                    this.getClassName("card", card.toLowerCase())
                ];

                return {
                    card: card,
                    classNames: classNames.join(" ")
                };
            }, this);
            html = Y.mustache(Trick.CARDS_TEMPLATE, {
                cards: cardsData
            });

            cardsNode.set("innerHTML", html);
        }

    }, {

        NAME: "trick",

        ATTRS: {

            cards: {
                value: []
            }

        },

        TRICK_TEMPLATE: ''
            + '<ul class="{{cardsCN}}">'
            + '</ul>',

        CARDS_TEMPLATE: ''
            + '{{#cards}}'
            +   '<li>'
            +     '<button type="button" class="{{classNames}}" data-event="card" data-event-argument="{{card}}" disabled="disabled">'
            +       '{{card}}'
            +     '</button>'
            +   '</li>'
            + '{{/cards}}'

    });

    Y.Bridge.Trick = Trick;

}, "0", { requires: ["widget"] });

