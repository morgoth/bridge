YUI.add("hand", function(Y) {

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

            html = Y.mustache(Hand.MAIN_TEMPLATE, {
                direction: this.get("direction"),
                directionCN: this.getClassName("direction"),
                joinCN: this.getClassName("join"),
                quitCN: this.getClassName("quit"),
                buttonsCN: this.getClassName("buttons"),
                name: this.get("name"),
                nameCN: this.getClassName("name"),
                cardsCN: this.getClassName("cards"),
                barCN: this.getClassName("bar")
            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("cardsChange", this._afterCardsChange);
            this.after("suitChange", this._afterSuitChange);
            this.after("nameChange", this._afterNameChange);
            this.after("disabledChange", this._afterDisabledChange);
            this.after("joinEnabledChange", this._afterJoinEnabledChange);
            this.after("quitEnabledChange", this._afterQuitEnabledChange);
            this.after("cardsEnabledChange", this._afterCardsEnabledChange);
            this.after("activeChange", this._afterActiveChange);
            contentBox.delegate("click", Y.bind(this._onButtonClick, this), "button[data-event]");
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

        _onButtonClick: function(event) {
            var eventName = event.target.getAttribute("data-event"),
                eventArgument = event.target.getAttribute("data-event-argument");

            this.fire(eventName, [eventArgument]);
        },

        syncUI: function() {
            this._uiSyncJoin();
            this._uiSyncQuit();
        },

        _afterCardsChange: function(event) {
            this._uiSetCards(event.newVal);
        },

        _afterSuitChange: function(event) {
            this._uiSetSuit(event.newVal);
        },

        _afterNameChange: function(event) {
            this._uiSetName(event.newVal);
        },

        _uiSyncJoin: function() {
            var joinNode,
                contentBox = this.get("contentBox"),
                joinEnabled = this.get("joinEnabled"),
                name = this.get("name");
            joinNode = contentBox.one("." + this.getClassName("join"));

            this._disableButton.apply(this, [joinNode]);
            if(!name && joinEnabled) {
                this._enableButton.apply(this, [joinNode]);
            }
        },

        _uiSyncQuit: function() {
            var quitNode,
                contentBox = this.get("contentBox"),
                quitEnabled = this.get("quitEnabled"),
                name = this.get("name");
            quitNode = contentBox.one("." + this.getClassName("quit"));

            this._disableButton.apply(this, [quitNode]);
            if(name && quitEnabled) {
                this._enableButton.apply(this, [quitNode]);
            }
        },

        _uiSetName: function(name) {
            var nameNode,
                contentBox = this.get("contentBox");

            nameNode = contentBox.one("." + this.getClassName("name"));
            nameNode.set("innerHTML", name);
            this._uiSyncJoin();
            this._uiSyncQuit();
        },

        _uiSetCards: function(cards) {
            var cardsHtml, cardsData, cardsNode,
                contentBox = this.get("contentBox");
            cardsData = Y.Array.map(cards, function(card) {
                var suit = Y.Bridge.parseSuit(card);

                return {
                    card: Y.Bridge.renderCard(card),
                    classNames: this.getClassName("card")
                };
            }, this);
            cardsNode = contentBox.one("." + this.getClassName("cards"));

            cardsHtml = Y.mustache(Hand.CARDS_TEMPLATE, { cards: cardsData });
            cardsNode.set("innerHTML", cardsHtml);
            this._uiSetCardsEnabled(this.get("cardsEnabled"));
        },

        _uiSetSuit: function(suit) {
            var className,
                cards = this.get("cards"),
                cardsEnabled = this.get("cardsEnabled"),
                contentBox = this.get("contentBox");

            if(suit && cardsEnabled && Y.Bridge.hasSuit(suit, cards)) {
                className = Y.ClassNameManager.getClassName("bridge", "card", suit.toLowerCase());

                this._uiSetCardsEnabled(false);
                contentBox.all("." + className).each(Y.bind(this._enableButton, this));
            }
        },

        _uiSetCardsEnabled: function(cardsEnabled) {
            var cards,
                contentBox = this.get("contentBox");
            cards = contentBox.all("." + this.getClassName("cards") + " button");

            if(cardsEnabled) {
                cards.each(Y.bind(this._enableButton, this));
            } else {
                cards.each(Y.bind(this._disableButton, this));
            }
        },

        _uiSetActive: function(active) {
            var barNode,
                activeCN = this.getClassName("bar", "active"),
                contentBox = this.get("contentBox");
            barNode = contentBox.one("." + this.getClassName("bar"));

            if(active) {
                barNode.addClass(activeCN);
            } else {
                barNode.removeClass(activeCN);
            }
        },

        _afterDisabledChange: function(event) {
            this.set("cardsEnabled", !event.newVal);
        },

        _enableButton: function(node) {
            var disabledCN = this.getClassName("button", "disabled"),
                enabledCN = this.getClassName("button", "enabled");

            node.replaceClass(disabledCN, enabledCN).removeAttribute("disabled");
        },

        _disableButton: function(node) {
            var disabledCN = this.getClassName("button", "disabled"),
                enabledCN = this.getClassName("button", "enabled");

            node.setAttribute("disabled", "disabled").replaceClass(enabledCN, disabledCN);
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

        MAIN_TEMPLATE: ''
            + '<ul class="{{cardsCN}}"></ul>'
            + '<div class="{{barCN}}">'
            +   '<div class="{{directionCN}}">{{direction}}</div>'
            +   '<div class="{{nameCN}}">{{name}}</div>'
            +   '<div class="{{buttonsCN}}">'
            +     '<button type="button" class="{{joinCN}}" data-event="join">Join</button>'
            +     '<button type="button" class="{{quitCN}}" data-event="quit">Quit</button>'
            +   '</div>'
            + '</div>',

        CARDS_TEMPLATE: ''
            + '{{#cards}}'
            +   '<li class="{{classNames}}">'
            +     '{{{card}}}'
            +   '</li>'
            + '{{/cards}}'

    });

    Y.Bridge.Hand = Hand;

}, "0", { requires: ["widget", "collection", "mustache", "helpers"] });
