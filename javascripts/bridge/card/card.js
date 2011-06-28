YUI.add("card", function (Y) {

    var Card = Y.Base.create("card", Y.Widget, [Y.WidgetChild], {

        BOUNDING_TEMPLATE : '<li></li>',

        renderUI: function () {
            this._renderCover();
            this._renderTopValue();
            this._renderBottomValue();
            this._renderSuits();
        },

        _renderCover: function () {
            this._coverNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("cover"));
        },

        _renderTopValue: function () {
            this._topNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("value")).addClass(this.getClassName("value", "top"));
            this._topValueNode = this._topNode.appendChild('<div>').addClass(this.getClassName("value", "value"));
            this._topSuitNode = this._topNode.appendChild('<div>').addClass(this.getClassName("value", "suit"));
        },

        _renderBottomValue: function () {
            this._bottomNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("value")).addClass(this.getClassName("value", "bottom")).addClass(this.getClassName("upside", "down"));
            this._bottomValueNode = this._bottomNode.appendChild('<div>').addClass(this.getClassName("value", "value"));
            this._bottomSuitNode = this._bottomNode.appendChild('<div>').addClass(this.getClassName("value", "suit"));
        },

        _renderSuits: function () {
            this._suitsNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("suits"));
            this._suitNodes = [];

            for (var i = 1; i < 17; i++) {
                this._suitNodes[i] = this._suitsNode.appendChild('<div>').addClass(this.getClassName("suit")).addClass(this.getClassName("suit", i));
                if (i > 10) {
                    this._suitNodes[i].addClass(this.getClassName("upside", "down"));
                }
            }
        },

        bindUI: function () {
            this.after("cardChange", this._afterCardChange);
            this.get("contentBox").after("click", this._afterContentBoxClick, this);
        },

        _afterCardChange: function (event) {
            this._syncCard(event.newVal, event.prevVal);
        },

        _afterContentBoxClick: function (event) {
            event.preventDefault();

            if (!this.get("disabled")) {
                this.fire("card", this.get("card"));
            }
        },

        syncUI: function () {
            this._syncCard(this.get("card"), "");
        },

        _syncCard: function (newCard, prevCard) {
            var prevSuit = prevCard[0],
                prevValue = prevCard[1],
                newSuit = newCard[0],
                newValue = newCard[1];

            newCard = (newCard === "") ? "UNKNOWN" : newCard;
            prevCard = (prevCard === "") ? "UNKNOWN" : prevCard;

            if (Y.Lang.isString(prevSuit)) {
                this.get("contentBox").removeClass(this.getClassName("suit", prevSuit.toLowerCase()));
            }

            if (Y.Lang.isString(newSuit)) {
                this.get("contentBox").addClass(this.getClassName("suit", newSuit.toLowerCase()));
            }

            if (Y.Lang.isString(prevValue)) {
                this.get("contentBox").removeClass(this.getClassName("value", prevValue.toLowerCase()));
            }

            if (Y.Lang.isString(newValue)) {
                this.get("contentBox").addClass(this.getClassName("value", newValue.toLowerCase()));
            }

            if (Y.Lang.isString(prevCard)) {
                this.get("contentBox").removeClass(this.getClassName(prevCard.toLowerCase()));
            }

            if (Y.Lang.isString(newCard)) {
                this.get("contentBox").addClass(this.getClassName(newCard.toLowerCase()));
            }
        }

    }, {

        ATTRS: {

            card: {
                value: ""
            }

        }

    });

    Y.namespace("Bridge").Card = Card;

}, "0", { requires: ["widget", "widget-child", "collection"] });
