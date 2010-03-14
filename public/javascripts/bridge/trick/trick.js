YUI.add("trick", function(Y) {

    Y.namespace("Bridge");

    function Trick() {
        Trick.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Trick, Y.Widget, {

        renderUI: function() {
            this._renderCards();
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

        _renderCards: function() {
            var contentBox = this.get("contentBox");

            this.cardsNode = Y.Node.create(Trick.OL_TEMPLATE);
            this.cardsNode.addClass(this.getClassName("cards"));

            contentBox.appendChild(this.cardsNode);
        },

        _uiSetCards: function(cards) {
            this.cardsNode.all("*").remove();

            Y.each(cards, function(card) {
                var className = this.getClassName("card", card),
                    cardNode = Y.Node.create(Trick.LI_TEMPLATE);

                cardNode.addClass(className);
                cardNode.set("innerHTML", card);

                this.cardsNode.appendChild(cardNode);
            }, this);
        }

    }, {

        NAME: "trick",

        ATTRS: {

            cards: {
                value: []
            }

        },

        OL_TEMPLATE: '<ol></ol>',

        LI_TEMPLATE: '<li></li>'

    });

    Y.Bridge.Trick = Trick;

}, "0", { requires: ["widget"] });

