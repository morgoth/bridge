YUI.add("hand", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT   = ".";

    Y.namespace("Bridge");

    function Hand() {
        Hand.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Hand, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            this.publish("join");
            this.publish("quit");
            this.publish("card");
            this.addTarget(host);
        },

        renderUI: function() {
            this._renderMainTemplate();
        },

        _renderMainTemplate: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Hand.MAIN_TEMPLATE, Hand);

            contentBox.setContent(html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("cardsChange", this._afterCardsChange);
            this.after("suitChange", this._afterSuitChange);
            this.after("nameChange", this._afterNameChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("disabledChange", this._afterDisabledChange);
            this.after("joinEnabledChange", this._afterJoinEnabledChange);
            this.after("quitEnabledChange", this._afterQuitEnabledChange);
            this.after("cardsEnabledChange", this._afterCardsEnabledChange);
            this.after("activeChange", this._afterActiveChange);

            this._uiHandleButtonEvents();
        },

        _afterJoinEnabledChange: function(event) {
            this._uiSyncJoin(event.newVal);
        },

        _afterQuitEnabledChange: function(event) {
            this._uiSyncQuit(event.newVal);
        },

        _afterCardsEnabledChange: function(event) {
            this._uiSetCardsEnabled(event.newVal);
        },

        _afterActiveChange: function(event) {
            this._uiSetActive(event.newVal);
        },

        syncUI: function() {
            this._uiSyncJoin(this.get("joinEnabled"));
            this._uiSyncQuit(this.get("quitEnabled"));
            this._uiSetName(this.get("name"));
            this._uiSetDirection(this.get("direction"));
        },

        _afterCardsChange: function(event) {
            this._uiSetCards(event.newVal);
        },

        _afterSuitChange: function(event) {
            this._uiSetSuit(event.newVal);
        },

        _afterDirectionChange: function(event) {
            this._uiSetDirection(event.newVal);
        },

        _afterNameChange: function(event) {
            this._uiSetName(event.newVal);
        },

        _uiSyncJoin: function(joinEnabled) {
            this._uiToggleButton(DOT + Hand.C_JOIN, joinEnabled);
        },

        _uiSyncQuit: function(quitEnabled) {
            this._uiToggleButton(DOT + Hand.C_QUIT, quitEnabled);
        },

        _uiSetDirection: function(direction) {
            this._uiSetContent(DOT + Hand.C_DIRECTION, direction);
        },

        _uiSetName: function(name) {
            this._uiSetContent(DOT + Hand.C_NAME, name);
        },

        _uiSetCards: function(cards) {
            var cardsData = Y.Array.map(cards, function(card) {
                return {
                    card: Y.Bridge.renderCard(card),
                    className: Hand.C_CARD
                };
            }, this);

            this._uiSetContent(DOT + Hand.C_CARDS, Y.mustache(Hand.CARDS_TEMPLATE, { cards: cardsData }));
            this._uiSetCardsEnabled(this.get("cardsEnabled"));
        },

        _uiSetSuit: function(suit) {
            this._uiSetCardsEnabled(this.get("cardsEnabled"));
        },

        _uiSetCardsEnabled: function(cardsEnabled) {
            var cards = this.get("cards"),
                trickSuit = this.get("suit");

            Y.each(cards, function(card) {
                var cardSuit = Y.Bridge.parseSuit(card);

                this._uiToggleButton(DOT + Y.Bridge.getCardClassName(card),
                                     cardsEnabled &&
                                     (!Y.Lang.isValue(trickSuit) ||
                                      !Y.Bridge.hasSuit(trickSuit, cards) ||
                                      (trickSuit === cardSuit)));
            }, this);
        },

        _uiSetActive: function(active) {
            var barNode,
                contentBox = this.get("contentBox");
            barNode = contentBox.one(DOT + Hand.C_BAR);

            if(active) {
                barNode.addClass(Hand.C_BAR_ACTIVE);
            } else {
                barNode.removeClass(Hand.C_BAR_ACTIVE);
            }
        },

        _afterDisabledChange: function(event) {
            this.set("cardsEnabled", !event.newVal);
        }

    }, {

        NAME: "hand",

        ATTRS: {

            host: {

            },

            direction: {
                validator: Y.Bridge.isDirection
            },

            userId: {

            },

            suit: {
                setter: function(suit) {
                    return (Y.Lang.isValue(suit) && Y.Bridge.isSuit(suit)) ? suit : undefined;
                }
            },

            name: {
                setter: function(value) {
                    return Y.Lang.isValue(value) ? value.toString() : undefined;
                }
            },

            cards: {
                value: []
            },

            active: {
                value: false,
                validator: Y.Lang.isBoolean
            },

            joinEnabled: {
                value: false,
                validator: Y.Lang.isBoolean,
                setter: function(value) {
                    return Y.Lang.isNumber(this.get("userId")) && value;
                }
            },

            quitEnabled: {
                value: false,
                validator: Y.Lang.isBoolean
            },

            cardsEnabled: {
                value: false,
                validator: Y.Lang.isBoolean
            }

        },

        C_DIRECTION:  getClassName("hand", "direction"),
        C_JOIN:       getClassName("hand", "join"),
        C_QUIT:       getClassName("hand", "quit"),
        C_BUTTONS:    getClassName("hand", "buttons"),
        C_NAME:       getClassName("hand", "name"),
        C_CARDS:      getClassName("hand", "cards"),
        C_BAR:        getClassName("hand", "bar"),
        C_BAR_ACTIVE: getClassName("hand", "bar", "active"),
        C_CARD:       getClassName("hand", "card"),

        MAIN_TEMPLATE: ''
            + '<ul class="{{C_CARDS}}"></ul>'
            + '<div class="{{C_BAR}}">'
            +   '<div class="{{C_DIRECTION}}">{{direction}}</div>'
            +   '<div class="{{C_NAME}}">{{name}}</div>'
            +   '<div class="{{C_BUTTONS}}">'
            +     '<button type="button" class="{{C_JOIN}}" data-event="join">Join</button>'
            +     '<button type="button" class="{{C_QUIT}}" data-event="quit">Quit</button>'
            +   '</div>'
            + '</div>',

        CARDS_TEMPLATE: ''
            + '{{#cards}}'
            +   '<li class="{{className}}">'
            +     '{{{card}}}'
            +   '</li>'
            + '{{/cards}}'

    });

    Y.augment(Hand, Y.Bridge.UiHelper);

    Y.Bridge.Hand = Hand;

}, "0", { requires: ["widget", "collection", "mustache", "helpers", "uihelper"] });
