YUI.add("trick", function(Y) {

    var each = Y.each,
        bind = Y.bind,
        Widget = Y.Widget,
        Node = Y.Node,
        TRICK = "trick",
        CARDS = "cards",
        CARD = "card",
        OL_TEMPLATE = '<ol></ol>',
        LI_TEMPLATE = '<li></li>';

    function Trick() {
        Trick.superclass.constructor.apply(this, arguments);
    }

    Y.mix(Trick, {
        NAME: TRICK,
        ATTRS: {
            cards: {
                value: []
            }
        }
    });

    Y.extend(Trick, Widget, {
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

            this.cardsNode = Node.create(OL_TEMPLATE);
            this.cardsNode.addClass(this.getClassName(CARDS));

            contentBox.appendChild(this.cardsNode);
        },

        _uiSetCards: function(cards) {
            this.cardsNode.all("*").remove();

            each(cards, function(card) {
                var className = this.getClassName(CARD, card),
                    cardNode = Node.create(LI_TEMPLATE);

                cardNode.addClass(className);
                cardNode.set("innerHTML", card);

                this.cardsNode.appendChild(cardNode);
            }, this);
        }
    });

    Y.Trick = Trick;

}, "0", {
    requires: ["widget"]
});

