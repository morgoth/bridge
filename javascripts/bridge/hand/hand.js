YUI.add("hand", function (Y) {

    var Hand = Y.Base.create("hand", Y.Bridge.CardList, [], {

        renderUI: function () {
            Hand.superclass.renderUI.apply(this, arguments);
            this._renderBar();
        },

        _renderBar: function () {
            this._barNode = this.get("contentBox").appendChild('<dl>').addClass(this.getClassName("bar"));
            this._directionNode = this._barNode.appendChild('<dt>').addClass(this.getClassName("direction"));
            this._nameNode = this._barNode.appendChild('<dd>').addClass(this.getClassName("name"));
        },

        bindUI: function () {
            Hand.superclass.bindUI.apply(this, arguments);
            this.after("suitChange", this._afterSuitChange);
            this.after("activeChange", this._afterActiveChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("nameChange", this._afterNameChange);
            this.after("joinEnabledChange", this._afterJoinEnabledChange);
            this._barNode.on("click", this._onBarClick, this);
        },

        _afterDisabledChange: function (event) {
            this._uiSyncSuit(this.get("suit"));
        },

        _afterSuitChange: function (event) {
            this._uiSyncSuit(event.newVal);
        },

        _afterActiveChange: function (event) {
            this._uiSyncActive(event.newVal);
        },

        _afterDirectionChange: function (event) {
            this._uiSyncDirection(event.newVal);
        },

        _afterNameChange: function (event) {
            this._uiSyncName(event.newVal);
        },

        _afterJoinEnabledChange: function (event) {
            this._uiSyncJoinEnabled(event.newVal);
        },

        _onBarClick: function (event) {
            if (this.get("joinEnabled") && this.get("userId")) {
                this.fire("join", [this.get("direction")]);
            }
        },

        syncUI: function () {
            Hand.superclass.syncUI.apply(this, arguments);
            this._uiSyncSuit(this.get("suit"));
            this._uiSyncDirection(this.get("direction"));
            this._uiSyncName(this.get("name"));
            this._uiSyncActive(this.get("active"));
        },

        _uiSyncCards: function (cards) {
            Hand.superclass._uiSyncCards.apply(this, arguments);
            this.each(function (child) {
                child.get("boundingBox").addClass(this.getClassName("card"));
            }, this);
        },

        _uiSyncSuit: function (suit) {
            var disabled = this.get("disabled"),
                hasCardInSuit = Y.Lang.isValue(Y.Array.find(this._items, function (child) {
                    return child.get("suit") === suit;
                }));

            this.each(function (child) {
                child.set("disabled", disabled || Y.Lang.isValue(suit) && hasCardInSuit && child.get("suit") !== suit);
            }, this);
        },

        _uiSyncDirection: function (direction) {
            this._directionNode.setContent(direction);
        },

        _uiSyncJoinEnabled: function (joinEnabled) {
            var name = (this.get("userId") && joinEnabled) ? "Click to join!" : this.get("name");
            this._uiSyncName(name);
        },

        _uiSyncName: function (name) {
            this._nameNode.setContent(name);
        },

        _uiSyncActive: function (active) {
            if (active) {
                this._barNode.addClass(this.getClassName("bar", "active"));
            } else {
                this._barNode.removeClass(this.getClassName("bar", "active"));
            }
        },

        _setSuit: function (suit) {
            return Y.Lang.isString(suit) && /^(C|D|H|S)$/.test(suit) ? suit : undefined;
        }

    }, {

        ATTRS: {

            direction: {
                value: ""
            },

            name: {
                value: ""
            },

            active: {
                value: false
            },

            joinEnabled: {
                value: false
            },

            suit: {
                value: undefined,
                setter: "_setSuit"
            },

            userId: {

            }

        }

    });

    Y.namespace("Bridge").Hand = Hand;

}, "0", { requires: ["card-list", "collection"] });
