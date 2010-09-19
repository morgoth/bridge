YUI.add("tricks", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Tricks = Y.Base.create("tricks", Y.Widget, [], {

        renderUI: function() {
            this._renderMainTemplate();
        },

        _renderMainTemplate: function() {
            this.get("contentBox").setContent(Y.mustache(Tricks.MAIN_TEMPLATE, Tricks));
        },

        syncUI: function() {
            this._uiSyncContract(this.get("contract"));
            this._uiSyncDeclarer(this.get("declarer"));
            this._uiSyncResultNS(this.get("resultNS"));
            this._uiSyncResultEW(this.get("resultEW"));
            this._uiSyncTricks(this.get("tricks"));
        },

        bindUI: function() {
            this.after("contractChange", this._afterContractChange);
            this.after("declarerChange", this._afterDeclarerChange);
            this.after("resultNSChange", this._afterResultNSChange);
            this.after("resultEWChange", this._afterResultEWChange);
            this.after("tricksChange", this._afterTricksChange);
        },

        _afterContractChange: function(event) {
            this._uiSyncContract(event.newVal);
        },

        _afterDeclarerChange: function(event) {
            this._uiSyncDeclarer(event.newVal);
        },

        _afterResultNSChange: function(event) {
            this._uiSyncResultNS(event.newVal);
        },

        _afterResultEWChange: function(event) {
            this._uiSyncResultEW(event.newVal);
        },

        _afterTricksChange: function(event) {
            this._uiSyncTricks(event.newVal);
        },

        _uiSyncContract: function(contract) {
            this.get("contentBox").one(DOT + Tricks.C_CONTRACT).setContent(contract ? Y.Bridge.renderContract(contract) : "");
        },

        _uiSyncDeclarer: function(declarer) {
            this.get("contentBox").one(DOT + Tricks.C_DECLARER).setContent(declarer || "");
        },

        _uiSyncResultNS: function(resultNS) {
            this.get("contentBox").one(DOT + Tricks.C_RESULT_NS).setContent("NS " + resultNS);
        },

        _uiSyncResultEW: function(resultEW) {
            this.get("contentBox").one(DOT + Tricks.C_RESULT_EW).setContent("EW " + resultEW);
        },

        _uiSyncTricks: function(tricks) {
            var tokens,
                player = this.get("player");

            tokens = Y.Array.map(tricks, function(trick) {
                return {
                    C_TRICK_COVER: Tricks.C_TRICK_COVER,
                    C_TRICK: Tricks.C_TRICK,
                    className: Y.Bridge.isSameSide(player, trick.winner) ? Tricks.C_TRICK_WON : Tricks.C_TRICK_LOST
                };
            }, this);

            this.get("contentBox").one(DOT + Tricks.C_TRICKS).setContent(Y.mustache(Tricks.TRICKS_TEMPLATE, { tricks: tokens }));
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

        C_TRICKS:      getClassName("tricks", "tricks"),
        C_TRICK:       getClassName("tricks", "trick"),
        C_TRICK_WON:   getClassName("tricks", "trick", "won"),
        C_TRICK_LOST:  getClassName("tricks", "trick", "lost"),
        C_TRICK_COVER: getClassName("tricks", "trick", "cover"),
        C_BAR:         getClassName("tricks", "bar"),
        C_CONTRACT:    getClassName("tricks", "contract"),
        C_DECLARER:    getClassName("tricks", "declarer"),
        C_RESULT_NS:   getClassName("tricks", "result", "ns"),
        C_RESULT_EW:   getClassName("tricks", "result", "ew"),

        MAIN_TEMPLATE: ''
            + '<ul class="{{C_TRICKS}}"></ul>'
            + '<div class="{{C_BAR}}">'
            +   '<div class="{{C_CONTRACT}}"></div>'
            +   '<div class="{{C_DECLARER}}"></div>'
            +   '<div class="{{C_RESULT_EW}}"></div>'
            +   '<div class="{{C_RESULT_NS}}"></div>'
            + '</div>',

        TRICKS_TEMPLATE: ''
            + '{{#tricks}}'
            +   '<li class="{{C_TRICK}}">'
            +     '<div class="{{className}}">'
            +       '<div class="{{C_TRICK_COVER}}"></div>'
            +     '</div>'
            +   '</li>'
            + '{{/tricks}}'

    });

    Y.Bridge.Tricks = Tricks;

}, "0", { requires: ["widget", "collection", "mustache", "helpers"] });
