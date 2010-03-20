YUI.add("biddingbox", function(Y) {

    Y.namespace("Bridge");

    function BiddingBox() {
        BiddingBox.superclass.constructor.apply(this, arguments);
    }

    Y.extend(BiddingBox, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            this.publish("bid");
            this.addTarget(host);
        },

        renderUI: function() {
            this._renderBiddingBox();
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("levelChange", this._afterLevelChange);
            this.after("contractChange", this._afterContractChange);
            this.after("doubleEnabledChange", this._afterDoubleEnabledChange);
            this.after("redoubleEnabledChange", this._afterRedoubleEnabledChange);

            contentBox.delegate("click", Y.bind(this._onButtonClick, this), "button[data-event]");
            this.on("pass", Y.bind(this.fire, this, "bid", ["PASS"]));
            this.on("x", Y.bind(this.fire, this, "bid", ["DOUBLE"]));
            this.on("xx", Y.bind(this.fire, this, "bid", ["REDOUBLE"]));
            this.on("level", this._onLevel);
            this.on("suit", this._onSuit);
        },

        syncUI: function() {
            this._uiSetContract(this.get("contract"));
            this._uiSetLevel(this.get("level"));
            this._uiSetDoubleEnabled(this.get("doubleEnabled"));
            this._uiSetRedoubleEnabled(this.get("redoubleEnabled"));
        },

        _onButtonClick: function(event) {
            var eventName = event.target.getAttribute("data-event"),
                eventArgument = event.target.getAttribute("data-event-argument");

            this.fire(eventName, [eventArgument]);
        },

        _onLevel: function(event) {
            this.set("level", event[0]);
        },

        _onSuit: function(event) {
            var level = this.get("level"),
                suit = event[0];

            this.fire("bid", [level + suit]);
        },

        _renderBiddingBox: function() {
            var html, modifiers, levels, suits,
                contentBox = this.get("contentBox");

            modifiers = Y.Array.map(BiddingBox.MODIFIERS, function(modifier, i) {
                return {
                    name: modifier,
                    className: this.getClassName("modifier", modifier.toLowerCase()),
                    eventName: modifier.toLowerCase()
                };
            }, this);

            levels = Y.Array.map(BiddingBox.LEVELS, function(level) {
                return {
                    name: level,
                    className: this.getClassName("level", level)
                };
            }, this);

            suits = Y.Array.map(BiddingBox.SUITS, function(suit) {
                return {
                    name: suit,
                    className: this.getClassName("suit", suit.toLowerCase())
                };
            }, this);

            html = Y.mustache(BiddingBox.BIDDING_BOX_TEMPLATE, {
                modifiers: modifiers,
                levels: levels,
                suits: suits
            });

            contentBox.set("innerHTML", html);
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

        _uiSetDoubleEnabled: function(doubleEnabled) {
            var doubleNode,
                contentBox = this.get("contentBox");

            doubleNode = contentBox.one("." + this.getClassName("modifier", "x"));

            if(doubleEnabled) {
                this._enableButton(doubleNode);
                this.set("redoubleEnabled", false);
            } else {
                this._disableButton(doubleNode);
            }
        },

        _uiSetRedoubleEnabled: function(redoubleEnabled) {
            var redoubleNode,
                contentBox = this.get("contentBox");
            redoubleNode = contentBox.one("." + this.getClassName("modifier", "xx"));

            if(redoubleEnabled) {
                this._enableButton(redoubleNode);
                this.set("doubleEnabled", false);
            } else {
                this._disableButton(redoubleNode);
            }
        },

        _uiSetContract: function(contract) {
            var levelNodes,
                contentBox = this.get("contentBox");
            levelNodes = contentBox.all("." + this.getClassName("level"));

            if(contract) {
                var contractLevel = parseInt(contract),
                    contractSuit = this._parseSuit(contract);

                Y.each(levelNodes, function(node, i) {
                    var level = i + 1;

                    if((contractLevel > level) || (contractLevel == level && contractSuit == "NT")) {
                        this._disableButton(node);
                    } else {
                        this._enableButton(node);
                    }
                }, this);
            } else {
                levelNodes.each(this._enableButton);
            }
        },

        _uiSetLevel: function(level) {
            var suitNodes,
                contract = this.get("contract"),
                contentBox = this.get("contentBox");
            suitNodes = contentBox.all("." + this.getClassName("suit"));

            if(level) {
                suitNodes.each(this._enableButton);

                if(contract) {
                    var contractLevel = parseInt(contract),
                        contractSuit = this._parseSuit(contract);

                    if(contractLevel === parseInt(level)) {
                        Y.each(suitNodes, function(node, i) {
                            var contractSuitIndex = Y.Array.indexOf(BiddingBox.SUITS, contractSuit);

                            if(i <= contractSuitIndex) {
                                this._disableButton(node);
                            } else {
                                this._enableButton(node);
                            }
                        }, this);
                    } else {
                        suitNodes.each(this._enableButton);
                    }
                } else {
                    suitNodes.each(this._enableButton);
                }
            } else {
                suitNodes.each(this._disableButton);
            }
        },

        _enableButton: function(node) {
            node.removeAttribute("disabled");
        },

        _disableButton: function(node) {
            node.setAttribute("disabled", "disabled");
        },

        _parseSuit: function(contract) {
            return contract.match(new RegExp(BiddingBox.SUITS.join("|")))[0];
        }

    }, {

        NAME: "biddingbox",

        ATTRS: {

            level: {
            },

            doubleEnabled: {
                value: false
            },

            redoubleEnabled: {
                value: false
            },

            contract: {
            },

            host: {
            }

        },

        LEVELS: [1, 2, 3, 4, 5, 6, 7],

        SUITS: ["C", "D", "H", "S", "NT"],

        MODIFIERS: ["PASS", "X", "XX"],

        BIDDING_BOX_TEMPLATE: + ''
            + '<div>'
            +   '{{#modifiers}}'
            +     '<button type="button" class="yui-biddingbox-modifier {{className}}" data-event="{{eventName}}">{{name}}</button>'
            +   '{{/modifiers}}'
            + '</div>'
            + '<div>'
            +   '{{#levels}}'
            +     '<button type="button" class="yui-biddingbox-level {{className}}" data-event="level" data-event-argument="{{name}}">'
            +       '{{name}}'
            +     '</button>'
            +   '{{/levels}}'
            + '</div>'
            + '<div>'
            +   '{{#suits}}'
            +     '<button type="button" class="yui-biddingbox-suit {{className}}" data-event="suit" data-event-argument="{{name}}">'
            +       '{{name}}'
            +     '</button>'
            +   '{{/suits}}'
            + '</div>'

    });

    Y.Bridge.BiddingBox = BiddingBox;

}, "0", { requires: ["widget", "mustache", "collection"] });
