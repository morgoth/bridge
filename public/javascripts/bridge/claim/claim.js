YUI.add("claim", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT   = ".";

    Y.namespace("Bridge");

    function Claim() {
        Claim.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Claim, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            if(host) {
                this.publish("claim");
                this.publish("cancel");
                this.addTarget(host);
            }
        },

        renderUI: function() {
            this._renderClaim();
        },

        _renderClaim: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Claim.CLAIM_TEMPLATE, Claim);
            contentBox.setContent(html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("tricksChange", this._afterTricksChange);
            this.after("maxTricksChange", this._afterMaxTricksChange);

            this.after("less", this._afterLess);
            this.after("more", this._afterMore);
            this.after("ok", this._afterOk);

            this._uiHandleButtonEvents();
        },

        _afterTricksChange: function(event) {
            this._uiSetTricks(event.newVal);
        },

        _afterMaxTricksChange: function(event) {
            this.set("tricks", event.newVal);
        },

        _afterOk: function(event) {
            var explanation = this._uiGetExplanation(),
                tricks = this.get("tricks");

            this.fire("claim", [tricks, explanation]);
        },

        _afterLess: function(event) {
            this.set("tricks", this.get("tricks") - 1);
        },

        _afterMore: function(event) {
            this.set("tricks", this.get("tricks") + 1);
        },

        syncUI: function() {
            this._uiSetTricks(this.get("maxTricks"));
        },

        _uiSetTricks: function(tricks) {
            var maxTricks = this.get("maxTricks");

            this._uiToggleButton(DOT + Claim.C_LESS_BUTTON, tricks !== 0);
            this._uiToggleButton(DOT + Claim.C_MORE_BUTTON, tricks !== maxTricks);

            this._uiSetContent(DOT + Claim.C_LESS_LABEL, "We get " + (tricks) + " more tricks");
            this._uiSetContent(DOT + Claim.C_MORE_LABEL, "You get " + (maxTricks - tricks) + " more tricks");
        },

        _uiGetExplanation: function() {
            var explanationInput,
                contentBox = this.get("contentBox");

            explanationInput = contentBox.one(DOT + Claim.C_EXPLANATION_INPUT);

            return explanationInput.get("value");
        },

        _uiSetExplanation: function(value) {
            var explanationInput,
                contentBox = this.get("contentBox");

            explanationInput = contentBox.one(DOT + Claim.C_EXPLANATION_INPUT);

            explanationInput.set("value", value || "");
        },

        _validateTricks: function(tricks) {
            var maxTricks = this.get("maxTricks");

            return Y.Lang.isNumber(tricks) && tricks >= 0 && tricks <= maxTricks;
        },

        _validateMaxTricks: function(maxTricks) {
            return Y.Lang.isNumber(maxTricks) && maxTricks >= 0 && maxTricks <= 13;
        }

    }, {

        NAME: "claim",

        ATTRS: {

            host: {

            },

            tricks: {
                validator: "_validateTricks",
                value: 13
            },

            maxTricks: {
                validator: "_validateMaxTricks",
                value: 13
            }

        },

        C_LESS:              getClassName("claim", "less"),
        C_LESS_LABEL:        getClassName("claim", "less", "label"),
        C_LESS_BUTTON:       getClassName("claim", "less", "button"),
        C_MORE:              getClassName("claim", "more"),
        C_MORE_LABEL:        getClassName("claim", "more", "label"),
        C_MORE_BUTTON:       getClassName("claim", "more", "button"),
        C_EXPLANATION:       getClassName("claim", "explanation"),
        C_EXPLANATION_INPUT: getClassName("claim", "explanation", "input"),
        C_BUTTONS:           getClassName("claim", "buttons"),
        C_BUTTONS_CLAIM:     getClassName("claim", "buttons", "claim"),
        C_BUTTONS_CANCEL:    getClassName("claim", "buttons", "cancel"),

        CLAIM_TEMPLATE: ''
            + '<ul>'
            +   '<li class="{{C_LESS}}">'
            +     '<span class="{{C_LESS_LABEL}}"></span>'
            +     '<button type="button" class="{{C_LESS_BUTTON}}" disabled="disabled" data-event="less">Less</button>'
            +   '</li>'
            +   '<li class="{{C_MORE}}">'
            +     '<span class="{{C_MORE_LABEL}}"></span>'
            +     '<button type="button" class="{{C_MORE_BUTTON}}" disabled="disabled" data-event="more">Less</button>'
            +   '</li>'
            +   '<li class="{{C_EXPLANATION}}">'
            +     '<label for="explanation">Explain: </label>'
            +     '<input id="explanation" name="explanation" type="text" class="{{C_EXPLANATION_INPUT}}" />'
            +   '</li>'
            +   '<li class="{{C_BUTTONS}}">'
            +     '<button type="button" class="{{C_BUTTONS_CLAIM}}" data-event="ok">Claim</button>'
            +     '<button type="button" class="{{C_BUTTONS_CANCEL}}" data-event="cancel">Cancel</button>'
            +   '</li>'
            + '</ul>'

    });

    Y.augment(Claim, Y.Bridge.UiHelper);

    Y.Bridge.Claim = Claim;

}, "0", { requires: ["widget", "mustache", "uihelper"] });
