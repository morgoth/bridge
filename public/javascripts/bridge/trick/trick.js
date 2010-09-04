YUI.add("trick", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

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
            this.after("leadChange", this._afterLeadChange);
            this.after("playerChange", this._afterPlayerChange);
        },

        syncUI: function() {
            this._uiSetCards(this.get("cards"));
        },

        _afterLeadChange: function(event) {
            this._uiSetCards(this.get("cards"));
        },

        _afterCardsChange: function(event) {
            this._uiSetCards(event.newVal);
        },

        _afterPlayerChange: function(event) {
            this._uiSetPlayer(event.newVal);
        },

        _renderTrick: function() {
            var html,
                contentBox = this.get("contentBox");
            html = Y.mustache(Trick.TRICK_TEMPLATE, Trick);

            contentBox.setContent(html);
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
            cardsNode = contentBox.one(DOT + Trick.C_CARDS);

            if(cards) {
                cardsData = Y.Array.map(cards, function(card, i) {
                    var direction,
                        position = (i +  positionDistance + 2) % 4; // TODO: test me please!
                    direction = Y.Bridge.DIRECTIONS[position];

                    return {
                        classNames: [Trick.C_CARD, Trick["C_CARD_" + direction]].join(" "),
                        card: Y.Bridge.renderCard(card)
                    };
                }, this);

                html = Y.mustache(Trick.CARDS_TEMPLATE, {
                    cards: cardsData
                });
            }

            cardsNode.setContent(html);
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

        C_CARDS:  getClassName("trick", "cards"),
        C_CARD:   getClassName("trick", "card"),
        C_CARD_N: getClassName("trick", "card", "n"),
        C_CARD_E: getClassName("trick", "card", "e"),
        C_CARD_S: getClassName("trick", "card", "s"),
        C_CARD_W: getClassName("trick", "card", "w"),

        TRICK_TEMPLATE: ''
            + '<ul class="{{C_CARDS}}">'
            + '</ul>',

        CARDS_TEMPLATE: ''
            + '{{#cards}}'
            +   '<li class="{{classNames}}">'
            +     '{{{card}}}'
            +   '</li>'
            + '{{/cards}}'

    });

    Y.Bridge.Trick = Trick;

}, "0", { requires: ["widget"] });
