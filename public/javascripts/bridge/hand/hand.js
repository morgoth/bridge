YUI.add("hand", function(Y) {

    Y.namespace("Bridge");

    function Hand() {
        Hand.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Hand, Y.Widget, {
        renderUI: function() {
            this._renderCards();
            this._renderBar();
            this._renderDirection();
            this._renderName();
            this._renderJoin();
            this._renderQuit();
        },

        bindUI: function() {
            this.after("cardsChange", this._afterCardsChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("nameChange", this._afterNameChange);
            this.after("disabledChange", this._afterDisabledChange);
            this.cardsNode.delegate("click", Y.bind(this._onCardClick, this), "button");
            this.joinNode.delegate("click", Y.bind(this.fire, this, "join"));
            this.quitNode.delegate("click", Y.bind(this.fire, this, "quit"));
        },

        syncUI: function() {
            this._uiSetCards(this.get("cards"));
            this._uiSetDirection(this.get("direction"));
            this._uiSetName(this.get("name"));
        },

        _afterCardsChange: function(event) {
            this._uiSetCards(event.newVal);
        },

        _afterDirectionChange: function(event) {
            this._uiSetDirection(event.newVal);
        },

        _afterNameChange: function(event) {
            this._uiSetName(event.newVal);
        },

        _afterDisabledChange: function(event) {
            this._uiSetDisabled(event.newVal);
        },

        _onCardClick: function(event) {
            var card = event.target.getAttribute("card");

            this.fire("card", [card]);
        },

        _renderCards: function() {
            var contentBox = this.get("contentBox");

            this.cardsNode = this._createButtonGroup(this.getClassName("cards"));

            contentBox.appendChild(this.cardsNode);
        },

        _renderBar: function() {
            var contentBox = this.get("contentBox");

            this.barNode = Y.Node.create(Hand.DIV_TEMPLATE);
            this.barNode.addClass(this.getClassName("bar"));

            contentBox.appendChild(this.barNode);
        },

        _renderDirection: function() {
            this.directionNode = Y.Node.create(Hand.SPAN_TEMPLATE);
            this.directionNode.addClass(this.getClassName("bar", "direction"));

            this.barNode.appendChild(this.directionNode);
        },

        _renderName: function() {
            this.nameNode = Y.Node.create(Hand.SPAN_TEMPLATE);
            this.nameNode.addClass(this.getClassName("bar", "name"));

            this.barNode.appendChild(this.nameNode);
        },

        _renderJoin: function() {
            this.joinNode = this._createButton("JOIN", this.getClassName("bar", "join"));
            this.barNode.appendChild(this.joinNode);
        },

        _renderQuit: function() {
            this.quitNode = this._createButton("QUIT", this.getClassName("bar", "quit"));
            this.barNode.appendChild(this.quitNode);
        },

        _uiSetCards: function(cards) {
            this.cardsNode.all("*").remove();

            Y.each(cards, function(card) {
                var className = this.getClassName("card", (card === "") ? "unknown" : card),
                    cardNode = this._createButtonGroupItem(card, className);

                cardNode.setAttribute("card", card);

                this.cardsNode.appendChild(cardNode);
            }, this);
        },

        _uiSetDirection: function(direction) {
            this.directionNode.set("innerHTML", direction);
        },

        _uiSetName: function(name) {
            this.nameNode.set("innerHTML", name);
            if(name === "") {
                this._enableButton(this.joinNode);
                this._disableButton(this.quitNode);
            } else {
                this._disableButton(this.joinNode);
                this._enableButton(this.quitNode);
            }
        },

        _uiSetDisabled: function(disabled) {
            if(disabled) {
                this.cardsNode && this.cardsNode.all("button").each(this._disableButton);
            } else {
                this.cardsNode && this.cardsNode.all("button").each(this._enableButton);
            }
        },

        _createButton: function(text, className) {
            var button = Y.Node.create(Hand.BUTTON_TEMPLATE);

            button.set("innerHTML", text);
            button.set("title", text);
            button.addClass(className);

            return button;
        },

        _createButtonGroup: function(className) {
            var buttonGroup = Y.Node.create(Hand.BUTTON_GROUP_TEMPLATE);

            buttonGroup.addClass(className);

            return buttonGroup;
        },

        _createButtonGroupItem: function(text, className) {
            var buttonGroupItem = Y.Node.create(Hand.BUTTON_GROUP_ITEM_TEMPLATE),
                button = this._createButton(text, className);

            buttonGroupItem.addClass(className);
            buttonGroupItem.appendChild(button);

            return buttonGroupItem;
        },

        _disableButton: function(node) {
            node.set("disabled", "disabled");
        },

        _enableButton: function(node) {
            node.removeAttribute("disabled");
        }
    }, {

        NAME: "hand",

        ATTRS: {

            direction: {
                value: "N"
            },

            name: {
                value: ""
            },

            cards: {
                value: []
            }

        },

        BUTTON_GROUP_TEMPLATE: '<ol></ol>',

        BUTTON_GROUP_ITEM_TEMPLATE: '<li></li>',

        BUTTON_TEMPLATE: '<button type="button"></button>',

        DIV_TEMPLATE: '<div></div>',

        SPAN_TEMPLATE: '<span></span>'

    });

    Y.Bridge.Hand = Hand;

}, "0", { requires: ["widget"] });
