YUI.add("biddingbox", function(Y) {

    Y.namespace("Bridge");

    function BiddingBox() {
        BiddingBox.superclass.constructor.apply(this, arguments);
    }

    Y.extend(BiddingBox, Y.Widget, {

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
            this.passNode.on("click", Y.bind(this._fireBidEvent, this, BiddingBox.PASS));
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
                this._enableButton(this.modifierNodes[BiddingBox.DOUBLE].one("button"));
                this.set("redouble", false);
            } else {
                this._disableButton(this.modifierNodes[BiddingBox.DOUBLE].one("button"));
            }
        },

        _uiSetRedouble: function(redbl) {
            if(redbl) {
                this._enableButton(this.modifierNodes[BiddingBox.REDOUBLE].one("button"));
                this.set("double", false);
            } else {
                this._disableButton(this.modifierNodes[BiddingBox.REDOUBLE].one("button"));
            }
        },

        _uiSetContract: function(contract) {
            if(contract) {
                var contractLevel = parseInt(contract),
                    contractSuit = this._parseSuit(contract);

                Y.each(this.levelNodes, function(node, level) {
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
                        Y.each(this.suitNodes, function(node, suit) {
                            var suitIndex = Y.Array.indexOf(BiddingBox.SUITS, suit),
                                contractSuitIndex = Y.Array.indexOf(BiddingBox.SUITS, contractSuit);

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
            Y.each(this.modifierNodes, function(node, modifier) {
                node.one("button").on("click", Y.bind(this._fireBidEvent, this, modifier));
            }, this);
        },

        _bindLevels: function() {
            Y.each(this.levelNodes, function(node, level) {
                node.one("button").on("click", Y.bind(this.set, this, "level", level));
            }, this);
        },

        _bindSuits: function() {
            Y.each(this.suitNodes, function(node, suit) {
                node.one("button").on("click", Y.bind(this._onSuitClick, this, suit));
            }, this);
        },

        _renderPassButton: function() {
            var contentBox = this.get("contentBox");

            this.passNode = this._createButton(BiddingBox.PASS, this.getClassName(BiddingBox.PASS.toLowerCase()));

            contentBox.appendChild(this.passNode);
        },

        _renderModifierButtons: function() {
            var contentBox = this.get("contentBox");

            this.modifierNodes = {};
            this.modifiersNode = this._createButtonGroup(this.getClassName("modifiers"));

            Y.each(BiddingBox.MODIFIERS, function(modifier) {
                var className = this.getClassName("modifier", modifier.toLowerCase()),
                    modifierNode = this._createButtonGroupItem(modifier, className);

                this.modifierNodes[modifier] = modifierNode;
                this.modifiersNode.appendChild(modifierNode);
            }, this);

            contentBox.appendChild(this.modifiersNode);
        },

        _renderLevelButtons: function() {
            var contentBox = this.get("contentBox");

            this.levelNodes = {};
            this.levelsNode = this._createButtonGroup(this.getClassName("levels"));

            Y.each(BiddingBox.LEVELS, function(level) {
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

            Y.each(BiddingBox.SUITS, function(suit) {
                var suitNode = this._createButtonGroupItem(suit, this.getClassName("suit", suit.toLowerCase()));

                this.suitNodes[suit] = suitNode;
                this.suitsNode.appendChild(suitNode);
            }, this);

            contentBox.appendChild(this.suitsNode);
        },

        _renderAlert: function() {
            var contentBox = this.get("contentBox");

            this.alertNode = Y.Node.create(BiddingBox.ALERT_TEMPLATE);
            contentBox.appendChild(this.alertNode);
        },

        _createButton: function(text, className) {
            var button = Y.Node.create(BiddingBox.BUTTON_TEMPLATE);

            button.set("innerHTML", text);
            button.set("title", text);
            button.addClass(className);

            return button;
        },

        _createButtonGroup: function(className) {
            var buttonGroup = Y.Node.create(BiddingBox.BUTTON_GROUP_TEMPLATE);

            buttonGroup.addClass(className);

            return buttonGroup;
        },

        _createButtonGroupItem: function(text, className) {
            var buttonGroupItem = Y.Node.create(BiddingBox.BUTTON_GROUP_ITEM_TEMPLATE),
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
            return contract.match(new RegExp(BiddingBox.SUITS.join("|")))[0];
        }

    }, {

        NAME: "biddingbox",

        ATTRS: {

            level: {
            },

            "double": {
            },

            redouble: {
            },

            contract: {
            }

        },

        LEVELS: [1, 2, 3, 4, 5, 6, 7],

        SUITS: ["C", "D", "H", "S", "NT"],

        PASS: "PASS",

        DOUBLE: "X",

        REDOUBLE: "XX",

        MODIFIERS: [BiddingBox.DOUBLE, BiddingBox.REDOUBLE],

        ALERT_TEMPLATE: '<input type="text"></input>',

        BUTTON_GROUP_TEMPLATE: '<ol></ol>',

        BUTTON_GROUP_ITEM_TEMPLATE: '<li></li>',

        BUTTON_TEMPLATE: '<button type="button"></button>'

    });

    Y.Bridge.BiddingBox = BiddingBox;

}, "0", { requires: ["widget"] });
