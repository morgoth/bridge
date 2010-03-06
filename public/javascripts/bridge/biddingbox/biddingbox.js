YUI.add("biddingbox", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        each = Y.each,
        indexOf = Y.Array.indexOf,
        bind = Y.bind,
        Widget = Y.Widget,
        Node = Y.Node,
        BIDDING_BOX = "biddingbox",
        LEVELS = [1, 2, 3, 4, 5, 6, 7],
        SUITS = ["C", "D", "H", "S", "NT"],
        PASS = "PASS",
        DOUBLE = "X",
        REDOUBLE = "XX",
        MODIFIERS = [DOUBLE, REDOUBLE],
        ALERT = "alert",
        ALERT_CLASS = getClassName(BIDDING_BOX, ALERT),
        ALERT_TEMPLATE = '<input type="text" class=' + ALERT_CLASS + '></input>',
        BUTTON_GROUP_TEMPLATE = '<ol></ol>',
        BUTTON_GROUP_ITEM_TEMPLATE = '<li></li>',
        BUTTON_TEMPLATE = '<button type="button"></button>';

    function BiddingBox() {
        BiddingBox.superclass.constructor.apply(this, arguments);
    }

    Y.mix(BiddingBox, {
        NAME: BIDDING_BOX,
        ATTRS: {
            level: {},
            "double": {},
            redouble: {},
            contract: {}
        }
    });

    Y.extend(BiddingBox, Widget, {
        renderUI: function() {
            this._renderPassButton();
            this._renderModifierButtons();
            this._renderLevelButtons();
            this._renderSuitButtons();
            this._renderAlert();
        },

        bindUI: function() {
            this.after("levelChange", this._afterLevelChange);
            this.after("contractChange", this._afterContractChange);
            this.after("doubleChange", this._afterDoubleChange);
            this.after("redoubleChange", this._afterRedoubleChange);
            this.passNode.on("click", bind(this._fireBidEvent, this, PASS));
            this._bindModifiers();
            this._bindLevels();
            this._bindSuits();
        },

        syncUI: function() {
            this._uiSetContract(this.get("contract"));
            this._uiSetLevel(this.get("level"));
            this._uiSetDouble(this.get("double"));
            this._uiSetRedouble(this.get("redouble"));
        },

        reset: function() {
            this.set("level", undefined);
            this.set("contract", undefined);
            this.set("double", undefined);
            this.set("redouble", undefined);
            this._uiSetAlert("");
        },

        _afterContractChange: function(event) {
            this._uiSetContract(event.newVal);
        },

        _afterLevelChange: function(event) {
            this._uiSetLevel(event.newVal);
        },

        _afterDoubleChange: function(event) {
            this._uiSetDouble(event.newVal);
        },

        _afterRedoubleChange: function(event) {
            this._uiSetRedouble(event.newVal);
        },

        _onSuitClick: function(suit) {
            var level = this.get("level");

            this._fireBidEvent(level + suit);
        },

        _fireBidEvent: function(bid) {
            var alert = this._uiGetAlert();

            this.fire("bid", [bid, alert]);
        },

        _uiSetDouble: function(dbl) {
            if(dbl) {
                this._enableButton(this.modifierNodes[DOUBLE].one("button"));
                this.set("redouble", false);
            } else {
                this._disableButton(this.modifierNodes[DOUBLE].one("button"));
            }
        },

        _uiSetRedouble: function(redbl) {
            if(redbl) {
                this._enableButton(this.modifierNodes[REDOUBLE].one("button"));
                this.set("double", false);
            } else {
                this._disableButton(this.modifierNodes[REDOUBLE].one("button"));
            }
        },

        _uiSetContract: function(contract) {
            if(contract) {
                var contractLevel = parseInt(contract),
                    contractSuit = this._parseSuit(contract);

                each(this.levelNodes, function(node, level) {
                    if((contractLevel > level) || (contractLevel == level && contractSuit == "NT")) {
                        this._disableButton(node.one("button"));
                    } else {
                        this._enableButton(node.one("button"));
                    }
                }, this);
            } else {
                this.levelsNode.all("button").each(this._enableButton);
            }
        },

        _uiSetLevel: function(level) {
            var disabledClassName = this.getClassName("suits", "disabled"),
                contract = this.get("contract");

            if(level) {
                this.suitsNode.removeClass(disabledClassName);
                if(contract) {
                    var contractLevel = parseInt(contract),
                        contractSuit = this._parseSuit(contract);

                    if(contractLevel === parseInt(level)) {
                        each(this.suitNodes, function(node, suit) {
                            var suitIndex = indexOf(SUITS, suit),
                                contractSuitIndex = indexOf(SUITS, contractSuit);

                            if(suitIndex <= contractSuitIndex) {
                                this._disableButton(node.one("button"));
                            } else {
                                this._enableButton(node.one("button"));
                            }
                        }, this);
                    } else {
                        this.suitsNode.all("button").each(this._enableButton);
                    }
                } else {
                    this.suitsNode.all("button").each(this._enableButton);
                }
            } else {
                this.suitsNode.addClass(disabledClassName);
                this.suitsNode.all("button").each(this._disableButton);
            }
        },

        _uiGetAlert: function() {
            return this.alertNode.get("value");
        },

        _uiSetAlert: function(alert) {
            return this.alertNode.set("value", alert);
        },

        _bindModifiers: function() {
            each(this.modifierNodes, function(node, modifier) {
                node.one("button").on("click", bind(this._fireBidEvent, this, modifier));
            }, this);
        },

        _bindLevels: function() {
            each(this.levelNodes, function(node, level) {
                node.one("button").on("click", bind(this.set, this, "level", level));
            }, this);
        },

        _bindSuits: function() {
            each(this.suitNodes, function(node, suit) {
                node.one("button").on("click", bind(this._onSuitClick, this, suit));
            }, this);
        },

        _renderPassButton: function() {
            var contentBox = this.get("contentBox");

            this.passNode = this._createButton(PASS, this.getClassName(PASS.toLowerCase()));

            contentBox.appendChild(this.passNode);
        },

        _renderModifierButtons: function() {
            var contentBox = this.get("contentBox");

            this.modifierNodes = {};
            this.modifiersNode = this._createButtonGroup(this.getClassName("modifiers"));

            each(MODIFIERS, function(modifier) {
                var modifierNode = this._createButtonGroupItem(modifier, this.getClassName("modifier", modifier.toLowerCase()));

                this.modifierNodes[modifier] = modifierNode;
                this.modifiersNode.appendChild(modifierNode);
            }, this);

            contentBox.appendChild(this.modifiersNode);
        },

        _renderLevelButtons: function() {
            var contentBox = this.get("contentBox");

            this.levelNodes = {};
            this.levelsNode = this._createButtonGroup(this.getClassName("levels"));

            each(LEVELS, function(level) {
                var levelNode = this._createButtonGroupItem(level, this.getClassName("level", level));

                this.levelNodes[level] = levelNode;
                this.levelsNode.appendChild(levelNode);
            }, this);

            contentBox.appendChild(this.levelsNode);
        },

        _renderSuitButtons: function() {
            var contentBox = this.get("contentBox");

            this.suitNodes = {};
            this.suitsNode = this._createButtonGroup(this.getClassName("suits"));

            each(SUITS, function(suit) {
                var suitNode = this._createButtonGroupItem(suit, this.getClassName("suit", suit.toLowerCase()));

                this.suitNodes[suit] = suitNode;
                this.suitsNode.appendChild(suitNode);
            }, this);

            contentBox.appendChild(this.suitsNode);
        },

        _renderAlert: function() {
            var contentBox = this.get("contentBox");

            this.alertNode = Node.create(ALERT_TEMPLATE);
            contentBox.appendChild(this.alertNode);
        },

        _createButton: function(text, className) {
            var button = Node.create(BUTTON_TEMPLATE);

            button.set("innerHTML", text);
            button.set("title", text);
            button.addClass(className);

            return button;
        },

        _createButtonGroup: function(className) {
            var buttonGroup = Node.create(BUTTON_GROUP_TEMPLATE);

            buttonGroup.addClass(className);

            return buttonGroup;
        },

        _createButtonGroupItem: function(text, className) {
            var buttonGroupItem = Node.create(BUTTON_GROUP_ITEM_TEMPLATE),
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
        },

        _parseSuit: function(contract) {
            return contract.match(new RegExp(SUITS.join("|")))[0];
        }
    });

    Y.BiddingBox = BiddingBox;

}, "0", {
    requires: ["widget"]
});
