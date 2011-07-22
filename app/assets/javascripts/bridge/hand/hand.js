YUI.add("hand", function (Y) {

    var Hand = Y.Base.create("hand", Y.Widget, [], {

        renderUI: function () {
            this._renderHandCards();
            this._renderHandBar();
        },

        _renderHandCards: function () {
            this._handCards = new Y.Bridge.HandCards().render(this.get("contentBox"));
        },

        _renderHandBar: function () {
            this._handBar = new Y.Bridge.HandBar().render(this.get("contentBox"));
        },

        bindUI: function () {
            this.after("cardsChange", this._afterCardsChange);
            this.after("nameChange", this._afterNameChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("activeChange", this._afterActiveChange);
        },

        _afterCardsChange: function (event) {
            this._syncCards(event.newVal);
        },

        _afterNameChange: function (event) {
            this._syncName(event.newVal);
        },

        _afterDirectionChange: function (event) {
            this._syncDirection(event.newVal);
        },

        _afterActiveChange: function (event) {
            this._syncActive(event.newVal);
        },

        syncUI: function () {
            this._syncCards(this.get("cards"));
            this._syncName(this.get("name"));
            this._syncDirection(this.get("direction"));
            this._syncActive(this.get("active"));
        },

        _syncCards: function (cards) {
            this._handCards.set("cards", cards);
        },

        _syncName: function (name) {
            this._handBar.set("name", name);
        },

        _syncDirection: function (direction) {
            this._handBar.set("direction", direction);
        },

        _syncActive: function (active) {
            this._handBar.set("active", active);
        }

    }, {

        ATTRS: {

            cards: {
                value: [],
                validator: Y.Lang.isArray
            },

            name: {
                validator: Y.Lang.isString
            },

            direction: {
                validator: Y.Bridge.isDirection
            },

            active: {
                validator: Y.Lang.isBoolean
            },

            visible: {
                value: false
            },

            disabled: {
                value: true
            }

        }

    });

    Y.namespace("Bridge").Hand = Hand;

}, "", { requires: ["widget", "handcards", "handbar"] });
