YUI.add("biddingbox", function (Y) {

    var BiddingBox = Y.Base.create("biddingbox", Y.Widget, [], {

        renderUI: function () {
            this._renderBiddingBox();
        },

        bindUI: function () {
            var contentBox = this.get("contentBox");
        },

        syncUI: function () {

        },

        _fireBidEvent: function (bid) {
            var alert = this._getAlert();
            this._resetAlert();
            this.fire("bid", [bid, alert]);
        },

        _getAlert: function () {

        },

        _resetAlert: function () {

        },

        _onLevel: function (event) {
            this.set("level", event[0]);
        },

        _onSuit: function (event) {
            var level = this.get("level"),
                suit = event[0];

            this._fireBidEvent(level + suit);
        },

        _renderBiddingBox: function () {
            var html,
                contentBox = this.get("contentBox"),

            contentBox.setContent(html);
        },

        _afterContractChange: function (event) {
            this.set("level", undefined);
            this._uiSetContract(event.newVal);
        },

        _afterLevelChange: function (event) {
            this._uiSetLevel(event.newVal);
        },

        _afterDoubleEnabledChange: function (event) {
            this._uiSetDoubleEnabled(event.newVal);
        },

        _afterRedoubleEnabledChange: function (event) {
            this._uiSetRedoubleEnabled(event.newVal);
        },

        _uiSetPassEnabled: function (passEnabled) {
            this._uiToggleButton(DOT + BiddingBox.C_MODIFIER_PASS, passEnabled);
        },

        _uiSetDoubleEnabled: function (doubleEnabled) {
            this._uiToggleButton(DOT + BiddingBox.C_MODIFIER_X, doubleEnabled);

            if (doubleEnabled) {
                this.set("redoubleEnabled", false);
            }
        },

        _uiSetRedoubleEnabled: function (redoubleEnabled) {
            this._uiToggleButton(DOT + BiddingBox.C_MODIFIER_XX, redoubleEnabled);

            if (redoubleEnabled) {
                this.set("doubleEnabled", false);
            }
        },

        _uiSetContract: function (contract) {
            var levels = [
                    DOT + BiddingBox.C_LEVEL_1,
                    DOT + BiddingBox.C_LEVEL_2,
                    DOT + BiddingBox.C_LEVEL_3,
                    DOT + BiddingBox.C_LEVEL_4,
                    DOT + BiddingBox.C_LEVEL_5,
                    DOT + BiddingBox.C_LEVEL_6,
                    DOT + BiddingBox.C_LEVEL_7
                ];

            Y.each(levels, function (button) {
                this._uiToggleButton(button, true);
            }, this);

            if (contract) {
                var contractLevel = parseInt(contract),
                    contractSuit = Y.Bridge.parseSuit(contract);

                Y.each(levels, function (button, i) {
                    var level = i + 1;

                    this._uiToggleButton(button, (contractLevel <= level) && (contractLevel !== level || contractSuit !== "NT"));
                }, this);
            }
        },

        _uiSetLevel: function (level) {
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

            Y.each(suits, function (button) {
                this._uiToggleButton(button, true);
            }, this);

            Y.each(levels, function (button) {
                Y.one(button).removeClass(BiddingBox.C_LEVEL_SELECTED);
            }, this);

            if (level) {
                Y.one(levels[parseInt(level) - 1]).addClass(BiddingBox.C_LEVEL_SELECTED);

                if (contract) {
                    var contractLevel = parseInt(contract),
                        contractSuit = Y.Bridge.parseSuit(contract);

                    if (contractLevel === parseInt(level)) {
                        Y.each(suits, function (button, i) {
                            var contractSuitIndex = Y.Bridge.suitPosition(contractSuit);

                            if (i <= contractSuitIndex) {
                                this._uiToggleButton(button, false);
                            }
                        }, this);
                    }
                }
            } else {
                Y.each(suits, function (button) {
                    this._uiToggleButton(button, false);
                }, this);
            }
        }

    }, {

        NAME: "biddingbox",

        ATTRS: {

            level: {
                setter: function (level) {
                    return (Y.Lang.isValue(level) && Y.Bridge.isLevel(level)) ? level : undefined;
                }
            },

            doubleEnabled: {
                setter: function (doubleEnabled) {
                    return !!doubleEnabled;
                },
                value: false
            },

            redoubleEnabled: {
                setter: function (redoubleEnabled) {
                    return !!redoubleEnabled;
                },
                value: false
            },

            contract: {
                setter: function (contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            }

        },

        // C_MODIFIER_PASS:  getClassName("biddingbox", "modifier", "pass"),
        // C_MODIFIER_X:     getClassName("biddingbox", "modifier", "x"),
        // C_MODIFIER_XX:    getClassName("biddingbox", "modifier", "xx"),

        // C_LEVEL_1:        getClassName("biddingbox", "level", "1"),
        // C_LEVEL_2:        getClassName("biddingbox", "level", "2"),
        // C_LEVEL_3:        getClassName("biddingbox", "level", "3"),
        // C_LEVEL_4:        getClassName("biddingbox", "level", "4"),
        // C_LEVEL_5:        getClassName("biddingbox", "level", "5"),
        // C_LEVEL_6:        getClassName("biddingbox", "level", "6"),
        // C_LEVEL_7:        getClassName("biddingbox", "level", "7"),
        // C_LEVEL_SELECTED: getClassName("biddingbox", "level", "selected"),

        // C_SUIT_C:         getClassName("biddingbox", "suit", "c"),
        // C_SUIT_D:         getClassName("biddingbox", "suit", "d"),
        // C_SUIT_H:         getClassName("biddingbox", "suit", "h"),
        // C_SUIT_S:         getClassName("biddingbox", "suit", "s"),
        // C_SUIT_NT:        getClassName("biddingbox", "suit", "nt"),

        // C_MODIFIERS:      getClassName("biddingbox", "modifiers"),
        // C_LEVELS:         getClassName("biddingbox", "levels"),
        // C_SUITS:          getClassName("biddingbox", "suits"),
        // C_ALERTS:         getClassName("biddingbox", "alerts"),
        // C_ALERT_INPUT:    getClassName("biddingbox", "alert", "input"),
        // C_ALERT_LABEL:    getClassName("biddingbox", "alert", "label"),

        // BIDDING_BOX_TEMPLATE: ''
        //     + '<ul class="{{C_MODIFIERS}}">'
        //     +   '{{#modifiers}}'
        //     +     '<li>'
        //     +       '<button type="button" class="yui3-biddingbox-modifier {{className}}" data-event="{{eventName}}">'
        //     +         '{{{name}}}'
        //     +       '</button>'
        //     +     '</li>'
        //     +   '{{/modifiers}}'
        //     + '</ul>'
        //     + '<ul class="{{C_LEVELS}}">'
        //     +   '{{#levels}}'
        //     +     '<li>'
        //     +       '<button type="button" class="yui3-biddingbox-level {{className}}" data-event="level" data-event-argument="{{name}}">'
        //     +         '{{{name}}}'
        //     +       '</button>'
        //     +     '</li>'
        //     +   '{{/levels}}'
        //     + '</ul>'
        //     + '<ul class="{{C_SUITS}}">'
        //     +   '{{#suits}}'
        //     +     '<li>'
        //     +       '<button type="button" class="yui3-biddingbox-suit {{className}}" data-event="suit" data-event-argument="{{eventArgument}}">'
        //     +         '{{{name}}}'
        //     +       '</button>'
        //     +     '</li>'
        //     +   '{{/suits}}'
        //     + '</ul>'
        //     + '<ul class="{{C_ALERTS}}">'
        //     +   '<li>'
        //     +     '<label for="alert" class="{{C_ALERT_LABEL}}">Alert</label>'
        //     +     '<input id="alert" name="alert" type="text" class="{{C_ALERT_INPUT}}" />'
        //     +   '</li>'
        //     + '</ul>'

    });

    Y.namespace("Bridge").BiddingBox = BiddingBox;

}, "0", { requires: ["widget"] });
