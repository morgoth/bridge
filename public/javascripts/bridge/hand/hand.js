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
                var suit = Y.Bridge.parseSuit(card),
                    name = (card !== "") ? card : "unknown",
                    classNames = [
                        this.getClassName("card"),
                        this.getClassName("card", name.toLowerCase())
                    ];

                if(suit) {
                    classNames.push(this.getClassName("card", suit.toLowerCase()));
                }

                return {
                    name: name,
                    classNames: classNames.join(" ")
                };
            }, this);
            cardsNode = contentBox.one("." + this.getClassName("cards"));

            cardsHtml = Y.mustache(Hand.CARDS_TEMPLATE, { cards: cardsData });
            cardsNode.set("innerHTML", cardsHtml);
            this._uiSetCardsEnabled(this.get("cardsEnabled"));
        },

        _uiSetSuit: function(suit) {
            var cardsEnabled = this.get("cardsEnabled"),
                contentBox = this.get("contentBox");

            if(suit && cardsEnabled) {
                this._uiSetCardsEnabled(false);
                contentBox.all("." + this.getClassName("card", suit.toLowerCase())).each(Y.bind(this._enableButton, this));
            }
        },

        _uiSetCardsEnabled: function(cardsEnabled) {
            var cards,
                contentBox = this.get("contentBox");
            cards = contentBox.all("."+ this.getClassName("cards") + " button");

            if(cardsEnabled) {
                cards.each(Y.bind(this._enableButton, this));
            } else {
                cards.each(Y.bind(this._disableButton, this));
            }
        },

        _afterDisabledChange: function(event) {
            this.set("cardsEnabled", !event.newVal);
        },

        _enableButton: function(node) {
            var className = this.getClassName("button", "disabled");

            node.removeAttribute("disabled").removeClass(className);
        },

        _disableButton: function(node) {
            var className = this.getClassName("button", "disabled");

            node.setAttribute("disabled", "disabled").addClass(className);
        }

    }, {

        NAME: "hand",

        ATTRS: {

            host: {
            },

            direction: {
                validator: Y.Bridge.isDirection
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

            joinEnabled: {
                value: false
            },

            quitEnabled: {
                value: false
            },

            cardsEnabled: {
                value: false
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
            +   '<li>'
            +     '<button type="button" class="{{classNames}}" data-event="card" data-event-argument="{{name}}">{{name}}</button>'
            +   '</li>'
            + '{{/cards}}'

    });

    Y.Bridge.Hand = Hand;

}, "0", { requires: ["widget", "collection", "mustache"] });
