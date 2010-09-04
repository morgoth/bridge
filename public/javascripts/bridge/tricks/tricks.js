YUI.add("tricks", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    function Tricks() {
        Tricks.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Tricks, Y.Widget, {

        renderUI: function() {
            this._renderMainTemplate();
        },

        _renderMainTemplate: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Tricks.MAIN_TEMPLATE, {
                C_TRICKS: Tricks.C_TRICKS,
                C_BAR: Tricks.C_BAR,
                C_CONTRACT: Tricks.C_CONTRACT,
                C_DECLARER: Tricks.C_DECLARER,
                C_RESULT_NS: Tricks.C_RESULT_NS,
                C_RESULT_EW: Tricks.C_RESULT_EW,
                resultNS: this.get("resultNS"),
                resultEW: this.get("resultEW"),
                contract: this.get("contract"),
                declarer: this.get("declarer")
            });

            contentBox.setContent(html);
        },

        bindUI: function() {
            this.after("contractChange", this._afterContractChange);
            this.after("declarerChange", this._afterDeclarerChange);
            this.after("resultNSChange", this._afterResultNSChange);
            this.after("resultEWChange", this._afterResultEWChange);
            this.after("tricksChange", this._afterTricksChange);
        },

        _afterContractChange: function(event) {
            this._uiSetContract(event.newVal);
        },

        _afterDeclarerChange: function(event) {
            this._uiSetDeclarer(event.newVal);
        },

        _afterResultNSChange: function(event) {
            this._uiSetResultNS(event.newVal);
        },

        _afterResultEWChange: function(event) {
            this._uiSetResultEW(event.newVal);
        },

        _afterTricksChange: function(event) {
            this._uiSetTricks(event.newVal);
        },

        _uiSetContract: function(contract) {
            this._uiSetContent(DOT + Tricks.C_CONTRACT, contract ? Y.Bridge.renderContract(contract) : "");
        },

        _uiSetDeclarer: function(declarer) {
            this._uiSetContent(DOT + Tricks.C_DECLARER, declarer || "");
        },

        _uiSetResultNS: function(resultNS) {
            this._uiSetContent(DOT + Tricks.C_RESULT_NS, "NS " + resultNS);
        },

        _uiSetResultEW: function(resultEW) {
            this._uiSetContent(DOT + Tricks.C_RESULT_EW, "EW " + resultEW);
        },

        _uiSetTricks: function(tricks) {
            var tricksData,
                player = this.get("player");

            tricksData = Y.Array.map(tricks, function(trick) {
                var classNames = [Tricks.C_TRICK];

                if(Y.Bridge.isSameSide(player, trick.winner)) {
                    classNames.push(Tricks.C_TRICK_WON);
                } else {
                    classNames.push(Tricks.C_TRICK_LOST);
                }

                return {
                    classNames: classNames.join(" ")
                };
            }, this);

            this._uiSetContent(DOT + Tricks.C_TRICKS, Y.mustache(Tricks.TRICKS_TEMPLATE, { tricks: tricksData }));
        }

    }, {

        NAME: "tricks",

        ATTRS: {

            host: {

            },

            contract: {
                setter: function(contract) {
                    return Y.Bridge.isContract(contract) ? contract : undefined;
                }
            },

            declarer: {
                setter: function(declarer) {
                    return Y.Bridge.isDirection(declarer) ? declarer : undefined;
                }
            },

            resultNS: {
                validator: Y.Lang.isNumber
            },

            resultEW: {
                validator: Y.Lang.isNumber
            },

            tricks: {
                validator: Y.Lang.isArray
            },

            player: {
                setter: function(player) {
                    return Y.Bridge.isDirection(player) ? player : "S";
                },
                value: "S"
            }

        },

        C_TRICKS:     getClassName("tricks", "tricks"),
        C_TRICK:      getClassName("tricks", "trick"),
        C_TRICK_WON:  getClassName("tricks", "trick", "won"),
        C_TRICK_LOST: getClassName("tricks", "trick", "lost"),
        C_BAR:        getClassName("tricks", "bar"),
        C_CONTRACT:   getClassName("tricks", "contract"),
        C_DECLARER:   getClassName("tricks", "declarer"),
        C_RESULT_NS:  getClassName("tricks", "result", "ns"),
        C_RESULT_EW:  getClassName("tricks", "result", "ew"),

        MAIN_TEMPLATE: ''
            + '<ul class="{{C_TRICKS}}"></ul>'
            + '<div class="{{C_BAR}}">'
            +   '<div class="{{C_CONTRACT}}">{{contract}}</div>'
            +   '<div class="{{C_DECLARER}}">{{declarer}}</div>'
            +   '<div class="{{C_RESULT_EW}}">EW {{resultEW}}</div>'
            +   '<div class="{{C_RESULT_NS}}">NS {{resultNS}}</div>'
            + '</div>',

        TRICKS_TEMPLATE: ''
            + '{{#tricks}}'
            +   '<li>'
            +     '<button class="{{classNames}}">&nbsp;</button>'
            +   '</li>'
            + '{{/tricks}}'

    });

    Y.augment(Tricks, Y.Bridge.UiHelper);

    Y.Bridge.Tricks = Tricks;

}, "0", { requires: ["widget", "collection", "mustache", "helpers", "uihelper"] });
