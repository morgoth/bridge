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
                    name: Y.Bridge.renderBid(modifier),
                    className: this.getClassName("modifier", modifier.toLowerCase()),
                    eventName: modifier.toLowerCase()
                };
            }, this);

            levels = Y.Array.map(Y.Bridge.LEVELS, function(level) {
                return {
                    name: level,
                    className: this.getClassName("level", level)
                };
            }, this);

            suits = Y.Array.map(Y.Bridge.SUITS, function(suit) {
                return {
                    name: Y.Bridge.renderSuit(suit),
                    eventArgument: suit,
                    className: this.getClassName("suit", suit.toLowerCase()),
                    suitCN: Y.ClassNameManager.getClassName("bridge", "suit", suit.toLowerCase())
                };
            }, this);

            html = Y.mustache(BiddingBox.BIDDING_BOX_TEMPLATE, {
                modifiersCN: this.getClassName("modifiers"),
                levelsCN: this.getClassName("levels"),
                suitsCN: this.getClassName("suits"),
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
                this._enableButton.apply(this, [doubleNode]);
                this.set("redoubleEnabled", false);
            } else {
                this._disableButton.apply(this, [doubleNode]);
            }
        },

        _uiSetRedoubleEnabled: function(redoubleEnabled) {
            var redoubleNode,
                contentBox = this.get("contentBox");
            redoubleNode = contentBox.one("." + this.getClassName("modifier", "xx"));

            if(redoubleEnabled) {
                this._enableButton.apply(this, [redoubleNode]);
                this.set("doubleEnabled", false);
            } else {
                this._disableButton.apply(this, [redoubleNode]);
            }
        },

        _uiSetContract: function(contract) {
            var levelNodes,
                contentBox = this.get("contentBox");
            levelNodes = contentBox.all("." + this.getClassName("level"));

            if(contract) {
                var contractLevel = parseInt(contract),
                    contractSuit = Y.Bridge.parseSuit(contract);

                Y.each(levelNodes, function(node, i) {
                    var level = i + 1;

                    if((contractLevel > level) || (contractLevel == level && contractSuit == "NT")) {
                        this._disableButton.apply(this, [node]);
                    } else {
                        this._enableButton.apply(this, [node]);
                    }
                }, this);
            } else {
                levelNodes.each(Y.bind(this._enableButton, this));
            }
        },

        _uiSetLevel: function(level) {
            var suitNodes,
                contract = this.get("contract"),
                contentBox = this.get("contentBox");
            suitNodes = contentBox.all("." + this.getClassName("suit"));

            if(level) {
                suitNodes.each(Y.bind(this._enableButton, this));

                if(contract) {
                    var contractLevel = parseInt(contract),
                        contractSuit = this._parseSuit(contract);

                    if(contractLevel === parseInt(level)) {
                        Y.each(suitNodes, function(node, i) {
                            var contractSuitIndex = Y.Array.indexOf(BiddingBox.SUITS, contractSuit);

                            if(i <= contractSuitIndex) {
                                this._disableButton.apply(this, [node]);
                            } else {
                                this._enableButton.apply(this, [node]);
                            }
                        }, this);
                    } else {
                        suitNodes.each(Y.bind(this._enableButton, this));
                    }
                } else {
                    suitNodes.each(Y.bind(this._enableButton, this));
                }
            } else {
                suitNodes.each(Y.bind(this._disableButton, this));
            }
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

        NAME: "biddingbox",

        ATTRS: {

            level: {
                validator: Y.Bridge.isLevel
            },

            doubleEnabled: {
                validator: Y.Lang.isBoolean,
                value: false
            },

            redoubleEnabled: {
                validator: Y.Lang.isBoolean,
                value: false
            },

            contract: {
                validator: Y.Bridge.isContract
            },

            host: {
            }

        },

        MODIFIERS: ["PASS", "X", "XX"],

        BIDDING_BOX_TEMPLATE: ''
            + '<ul class="{{modifiersCN}}">'
            +   '{{#modifiers}}'
            +     '<li>'
            +       '<button type="button" class="yui-biddingbox-modifier {{className}}" data-event="{{eventName}}">'
            +         '{{{name}}}'
            +       '</button>'
            +     '</li>'
            +   '{{/modifiers}}'
            + '</ul>'
            + '<ul class="{{levelsCN}}">'
            +   '{{#levels}}'
            +     '<li>'
            +       '<button type="button" class="yui-biddingbox-level {{className}}" data-event="level" data-event-argument="{{name}}">'
            +         '{{{name}}}'
            +       '</button>'
            +     '</li>'
            +   '{{/levels}}'
            + '</ul>'
            + '<ul class="{{suitsCN}}">'
            +   '{{#suits}}'
            +     '<li>'
            +       '<button type="button" class="yui-biddingbox-suit {{className}}" data-event="suit" data-event-argument="{{eventArgument}}">'
            +         '<span class="{{suitCN}}">{{{name}}}</span>'
            +       '</button>'
            +     '</li>'
            +   '{{/suits}}'
            + '</ul>'

    });

    Y.Bridge.BiddingBox = BiddingBox;

}, "0", { requires: ["widget", "mustache", "collection", "helpers"] });
