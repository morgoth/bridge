YUI.add("hand", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Hand = Y.Base.create("hand", Y.Bridge.CardList, [], {

        initializer: function() {
            this.publish("card");
            this.publish("join");
            this.publish("quit");
            this.addTarget(this.get("host"));
        },

        renderUI: function() {
            Hand.superclass.renderUI.apply(this, arguments);
            this._renderBar();
        },

        _renderBar: function() {
            this.get("contentBox").append(Y.mustache(Hand.BAR_TEMPLATE, Hand));
        },

        bindUI: function() {
            Hand.superclass.bindUI.apply(this, arguments);
            this.after("suitChange", this._afterSuitChange);
            this.after("activeChange", this._afterActiveChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("nameChange", this._afterNameChange);
            this.get("contentBox").one(DOT + Hand.C_BAR).on("click", this._onBarClick, this);
        },

        _afterDisabledChange: function(event) {
            this._uiSyncSuit(this.get("suit"));
        },

        _afterSuitChange: function(event) {
            this._uiSyncSuit(event.newVal);
        },

        _afterActiveChange: function(event) {
            this._uiSyncActive(event.newVal);
        },

        _afterDirectionChange: function(event) {
            this._uiSyncDirection(event.newVal);
        },

        _afterNameChange: function(event) {
            this._uiSyncName(event.newVal);
        },

        _onBarClick: function(event) {
            if(this.get("joinEnabled")) {
                this.fire("join", [this.get("direction")]);
            }
            if(this.get("quitEnabled")) {
                this.fire("quit", [this.get("direction")]);
            }
        },

        syncUI: function() {
            Hand.superclass.syncUI.apply(this, arguments);
            this._uiSyncSuit(this.get("suit"));
            this._uiSyncDirection(this.get("direction"));
            this._uiSyncName(this.get("name"));
            this._uiSyncActive(this.get("active"));
        },

        _uiSyncSuit: function(suit) {
            var disabled = this.get("disabled"),
                hasCardInSuit = Y.Lang.isValue(Y.Array.find(this._items, function(child) {
                    return child.get("suit") === suit;
                }));

            this.each(function(child) {
                child.set("disabled", disabled || Y.Lang.isValue(suit) && hasCardInSuit && child.get("suit") !== suit);
            }, this);
        },

        _uiSyncDirection: function(direction) {
            this.get("contentBox").one(DOT + Hand.C_DIRECTION).setContent(direction);
        },

        _uiSyncName: function(name) {
            this.get("contentBox").one(DOT + Hand.C_NAME).setContent(name);
        },

        _uiSyncActive: function(active) {
            var barNode = this.get("contentBox").one(DOT + Hand.C_BAR);

            if(active) {
                barNode.addClass(Hand.C_BAR_ACTIVE);
            } else {
                barNode.removeClass(Hand.C_BAR_ACTIVE);
            }
        },

        _setSuit: function(suit) {
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

            quitEnabled: {
                value: false
            },

            // DEPRECATED
            cardsEnabled: {
                setter: function(value) {
                    this.set("disabled", !value);
                }
            },

            suit: {
                value: undefined,
                setter: "_setSuit"
            },

            host: {
            }

        },

        C_DIRECTION:  getClassName("hand", "direction"),
        C_NAME:       getClassName("hand", "name"),
        C_CARDS:      getClassName("hand", "cards"),
        C_BAR:        getClassName("hand", "bar"),
        C_BAR_ACTIVE: getClassName("hand", "bar", "active"),
        C_CARD:       getClassName("hand", "card"),
        C_CARDS:      getClassName("hand", "cards"),

        BAR_TEMPLATE: ''
            + '<dl class="{{C_BAR}}">'
            +   '<dd class="{{C_DIRECTION}}">{{direction}}</dd>'
            +   '<dt class="{{C_NAME}}">{{name}}</dt>'
            + '</dl>'

    });

    Y.Bridge.Hand = Hand;

}, "0", { requires: ["cardlist", "collection"] });
