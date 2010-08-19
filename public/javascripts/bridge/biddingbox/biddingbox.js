YUI.add("biddingbox", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT   = ".";

    Y.namespace("Bridge");

    function BiddingBox() {
        BiddingBox.superclass.constructor.apply(this, arguments);
    }

    Y.extend(BiddingBox, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            if(host) {
                this.publish("bid");
                this.addTarget(host);
            }
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
            this.on("pass", Y.bind(this._fireBidEvent, this, "PASS"));
            this.on("x", Y.bind(this._fireBidEvent, this, "X"));
            this.on("xx", Y.bind(this._fireBidEvent, this, "XX"));
            this.on("level", this._onLevel);
            this.on("suit", this._onSuit);
        },

        syncUI: function() {
            this._uiSetContract(this.get("contract"));
            this._uiSetLevel(this.get("level"));
            this._uiSetDoubleEnabled(this.get("doubleEnabled"));
            this._uiSetRedoubleEnabled(this.get("redoubleEnabled"));
        },

        _fireBidEvent: function(bid) {
            var alert = this._getAlert();

            this._resetAlert();
            this.fire("bid", [bid, alert]);
        },

        _getAlert: function() {
            return this._uiGetValue(DOT + BiddingBox.C_ALERT_INPUT);
        },

        _resetAlert: function() {
            return this._uiSetValue(DOT + BiddingBox.C_ALERT_INPUT, "");
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

            this._fireBidEvent(level + suit);
        },

        _renderBiddingBox: function() {
            var html,
                contentBox = this.get("contentBox"),
                modifiers = [
                    { className: BiddingBox.C_MODIFIER_PASS, eventName: "pass", name: Y.Bridge.renderBid("PASS") },
                    { className: BiddingBox.C_MODIFIER_X, eventName: "x", name: Y.Bridge.renderBid("X") },
                    { className: BiddingBox.C_MODIFIER_XX, eventName: "xx", name: Y.Bridge.renderBid("XX") }
                ], levels = [
                    { name: "1", className: BiddingBox.C_LEVEL_1 },
                    { name: "2", className: BiddingBox.C_LEVEL_2 },
                    { name: "3", className: BiddingBox.C_LEVEL_3 },
                    { name: "4", className: BiddingBox.C_LEVEL_4 },
                    { name: "5", className: BiddingBox.C_LEVEL_5 },
                    { name: "6", className: BiddingBox.C_LEVEL_6 },
                    { name: "7", className: BiddingBox.C_LEVEL_7 }
                ], suits = [
                    { name: Y.Bridge.renderSuit("C"), eventArgument: "C", className: BiddingBox.C_SUIT_C },
                    { name: Y.Bridge.renderSuit("D"), eventArgument: "D", className: BiddingBox.C_SUIT_D },
                    { name: Y.Bridge.renderSuit("H"), eventArgument: "H", className: BiddingBox.C_SUIT_H },
                    { name: Y.Bridge.renderSuit("S"), eventArgument: "S", className: BiddingBox.C_SUIT_S },
                    { name: Y.Bridge.renderSuit("NT"), eventArgument: "NT", className: BiddingBox.C_SUIT_NT }
                ];

            html = Y.mustache(BiddingBox.BIDDING_BOX_TEMPLATE, {
                C_MODIFIERS: BiddingBox.C_MODIFIERS,
                C_LEVELS: BiddingBox.C_LEVELS,
                C_SUITS: BiddingBox.C_SUITS,
                C_ALERTS: BiddingBox.C_ALERTS,
                C_ALERT_LABEL: BiddingBox.C_ALERT_LABEL,
                C_ALERT_INPUT: BiddingBox.C_ALERT_INPUT,
                modifiers: modifiers,
                levels: levels,
                suits: suits
            });

            contentBox.setContent(html);
        },

        _afterContractChange: function(event) {
            this.set("level", undefined);
            this._uiSetContract(event.newVal);
        },

        _afterLevelChange: function(event) {
            this._uiSetLevel(event.newVal);
        },

        _afterDoubleEnabledChange: function(event) {
            this._uiSetDoubleEnabled(event.newVal);
        },

        _afterRedoubleEnabledChange: function(event) {
            this._uiSetRedoubleEnabled(event.newVal);
        },

        _uiSetDoubleEnabled: function(doubleEnabled) {
            this._uiToggleButton(DOT + BiddingBox.C_MODIFIER_X, doubleEnabled);

            if(doubleEnabled) {
                this.set("redoubleEnabled", false);
            }
        },

        _uiSetRedoubleEnabled: function(redoubleEnabled) {
            this._uiToggleButton(DOT + BiddingBox.C_MODIFIER_XX, redoubleEnabled);

            if(redoubleEnabled) {
                this.set("doubleEnabled", false);
            }
        },

        _uiSetContract: function(contract) {
            var levels = [
                    DOT + BiddingBox.C_LEVEL_1,
                    DOT + BiddingBox.C_LEVEL_2,
                    DOT + BiddingBox.C_LEVEL_3,
                    DOT + BiddingBox.C_LEVEL_4,
                    DOT + BiddingBox.C_LEVEL_5,
                    DOT + BiddingBox.C_LEVEL_6,
                    DOT + BiddingBox.C_LEVEL_7
                ];

            Y.each(levels, function(button) {
                this._uiToggleButton(button, true);
            }, this);

            if(contract) {
                var contractLevel = parseInt(contract),
                    contractSuit = Y.Bridge.parseSuit(contract);

                Y.each(levels, function(button, i) {
                    var level = i + 1;

                    this._uiToggleButton(button, (contractLevel <= level) && (contractLevel !== level || contractSuit !== "NT"));
                }, this);
            }
        },

        _uiSetLevel: function(level) {
            var contract = this.get("contract"),
                levels = [
                    DOT + BiddingBox.C_LEVEL_1,
                    DOT + BiddingBox.C_LEVEL_2,
                    DOT + BiddingBox.C_LEVEL_3,
                    DOT + BiddingBox.C_LEVEL_4,
                    DOT + BiddingBox.C_LEVEL_5,
                    DOT + BiddingBox.C_LEVEL_6,
                    DOT + BiddingBox.C_LEVEL_7
                ], suits = [
                    DOT + BiddingBox.C_SUIT_C,
                    DOT + BiddingBox.C_SUIT_D,
                    DOT + BiddingBox.C_SUIT_H,
                    DOT + BiddingBox.C_SUIT_S,
                    DOT + BiddingBox.C_SUIT_NT
                ];

            Y.each(suits, function(button) {
                this._uiToggleButton(button, true);
            }, this);

            Y.each(levels, function(button) {
                Y.one(button).removeClass(BiddingBox.C_LEVEL_SELECTED);
            }, this);

            if(level) {
                Y.one(levels[parseInt(level) - 1]).addClass(BiddingBox.C_LEVEL_SELECTED);

                if(contract) {
                    var contractLevel = parseInt(contract),
                        contractSuit = Y.Bridge.parseSuit(contract);

                    if(contractLevel === parseInt(level)) {
                        Y.each(suits, function(button, i) {
                            var contractSuitIndex = Y.Bridge.suitPosition(contractSuit);

                            if(i <= contractSuitIndex) {
                                this._uiToggleButton(button, false);
                            }
                        }, this);
                    }
                }
            } else {
                Y.each(suits, function(button) {
                    this._uiToggleButton(button, false);
                }, this);
            }
        }

    }, {

        NAME: "biddingbox",

        ATTRS: {

            level: {
                setter: function(level) {
                    return (Y.Lang.isValue(level) && Y.Bridge.isLevel(level)) ? level : undefined;
                }
            },

            doubleEnabled: {
                setter: function(doubleEnabled) {
                    return !!doubleEnabled;
                },
                value: false
            },

            redoubleEnabled: {
                setter: function(redoubleEnabled) {
                    return !!redoubleEnabled;
                },
                value: false
            },

            contract: {
                setter: function(contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            },

            host: {
            }

        },

        C_MODIFIER_PASS: getClassName("biddingbox", "modifier", "pass"),
        C_MODIFIER_X: getClassName("biddingbox", "modifier", "x"),
        C_MODIFIER_XX: getClassName("biddingbox", "modifier", "xx"),

        C_LEVEL_1: getClassName("biddingbox", "level", "1"),
        C_LEVEL_2: getClassName("biddingbox", "level", "2"),
        C_LEVEL_3: getClassName("biddingbox", "level", "3"),
        C_LEVEL_4: getClassName("biddingbox", "level", "4"),
        C_LEVEL_5: getClassName("biddingbox", "level", "5"),
        C_LEVEL_6: getClassName("biddingbox", "level", "6"),
        C_LEVEL_7: getClassName("biddingbox", "level", "7"),
        C_LEVEL_SELECTED: getClassName("biddingbox", "level", "selected"),

        C_SUIT_C: getClassName("biddingbox", "suit", "c"),
        C_SUIT_D: getClassName("biddingbox", "suit", "d"),
        C_SUIT_H: getClassName("biddingbox", "suit", "h"),
        C_SUIT_S: getClassName("biddingbox", "suit", "s"),
        C_SUIT_NT: getClassName("biddingbox", "suit", "nt"),

        C_MODIFIERS: getClassName("biddingbox", "modifiers"),
        C_LEVELS: getClassName("biddingbox", "levels"),
        C_SUITS: getClassName("biddingbox", "suits"),
        C_ALERTS: getClassName("biddingbox", "alerts"),
        C_ALERT_INPUT: getClassName("biddingbox", "alert", "input"),
        C_ALERT_LABEL: getClassName("biddingbox", "alert", "label"),

        BIDDING_BOX_TEMPLATE: ''
            + '<ul class="{{C_MODIFIERS}}">'
            +   '{{#modifiers}}'
            +     '<li>'
            +       '<button type="button" class="yui3-biddingbox-modifier {{className}}" data-event="{{eventName}}">'
            +         '{{{name}}}'
            +       '</button>'
            +     '</li>'
            +   '{{/modifiers}}'
            + '</ul>'
            + '<ul class="{{C_LEVELS}}">'
            +   '{{#levels}}'
            +     '<li>'
            +       '<button type="button" class="yui3-biddingbox-level {{className}}" data-event="level" data-event-argument="{{name}}">'
            +         '{{{name}}}'
            +       '</button>'
            +     '</li>'
            +   '{{/levels}}'
            + '</ul>'
            + '<ul class="{{C_SUITS}}">'
            +   '{{#suits}}'
            +     '<li>'
            +       '<button type="button" class="yui3-biddingbox-suit {{className}}" data-event="suit" data-event-argument="{{eventArgument}}">'
            +         '{{{name}}}'
            +       '</button>'
            +     '</li>'
            +   '{{/suits}}'
            + '</ul>'
            + '<ul class="{{C_ALERTS}}">'
            +   '<li>'
            +     '<label for="alert" class="{{C_ALERT_LABEL}}">Alert</label>'
            +     '<input id="alert" name="alert" type="text" class="{{C_ALERT_INPUT}}" />'
            +   '</li>'
            + '</ul>'

    });

    Y.augment(BiddingBox, Y.Bridge.UiHelper);

    Y.Bridge.BiddingBox = BiddingBox;

}, "0", { requires: ["widget", "mustache", "collection", "helpers", "uihelper"] });
