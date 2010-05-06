YUI.add("claim", function(Y) {

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

            html = Y.mustache(Claim.CLAIM_TEMPLATE, {
                lessCN:             this.getClassName("less"),
                lessLabelCN:        this.getClassName("less", "label"),
                lessButtonCN:       this.getClassName("less", "button"),
                moreCN:             this.getClassName("more"),
                moreLabelCN:        this.getClassName("more", "label"),
                moreButtonCN:       this.getClassName("more", "button"),
                explanationCN:      this.getClassName("explanation"),
                explanationInputCN: this.getClassName("explanation", "input"),
                buttonsCN:          this.getClassName("buttons"),
                buttonsClaimCN:     this.getClassName("buttons", "claim"),
                buttonsCancelCN:    this.getClassName("buttons", "cancel")
            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("tricksChange", this._afterTricksChange);
            this.after("maxTricksChange", this._afterMaxTricksChange);

            contentBox.delegate("click", Y.bind(this._onButtonClick, this), "button[data-event]");

            this.after("less", this._afterLess);
            this.after("more", this._afterMore);
            this.after("ok", this._afterOk);
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

        _onButtonClick: function(event) {
            var eventName = event.target.getAttribute("data-event"),
                eventArgument = event.target.getAttribute("data-event-argument");

            this.fire(eventName, [eventArgument]);
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
            var lessLabel, lessButton, moreLabel, moreButton, claimButton,
                maxTricks = this.get("maxTricks"),
                contentBox = this.get("contentBox");
            lessLabel = contentBox.one("." + this.getClassName("less", "label"));
            lessButton = contentBox.one("." + this.getClassName("less", "button"));
            moreLabel = contentBox.one("." + this.getClassName("more", "label"));
            moreButton = contentBox.one("." + this.getClassName("more", "button"));
            claimButton = contentBox.one("." + this.getClassName("buttons", "claim"));

            if(tricks === 0) {
                this._disableButton(lessButton);
            } else {
                this._enableButton(lessButton);
            }

            if(tricks === maxTricks) {
                this._disableButton(moreButton);
            } else {
                this._enableButton(moreButton);
            }

            lessLabel.set("innerHTML", "We get " + (tricks) + " more tricks");
            moreLabel.set("innerHTML", "You get " + (maxTricks - tricks) + " more tricks");
        },

        _uiGetExplanation: function() {
            var explanationInput,
                contentBox = this.get("contentBox");

            explanationInput = contentBox.one("." + this.getClassName("explanation", "input"));

            return explanationInput.get("value");
        },

        _uiSetExplanation: function(value) {
            var explanationInput,
                contentBox = this.get("contentBox");

            explanationInput = contentBox.one("." + this.getClassName("explanation", "input"));

            explanationInput.set("value", value || "");
        },

        _validateTricks: function(tricks) {
            var maxTricks = this.get("maxTricks");

            return Y.Lang.isNumber(tricks) && tricks >= 0 && tricks <= maxTricks;
        },

        _validateMaxTricks: function(maxTricks) {
            return Y.Lang.isNumber(maxTricks) && maxTricks >= 0 && maxTricks <= 13;
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

        NAME: "claim",

        ATTRS: {

            host: {

            },

            tricks: {
                validator: this._validateTricks,
                value: 13
            },

            maxTricks: {
                validator: this._validateMaxTricks,
                value: 13
            }

        },

        CLAIM_TEMPLATE: ''
            + '<ul>'
            +   '<li class="{{lessCN}}">'
            +     '<span class="{{lessLabelCN}}"></span>'
            +     '<button type="button" class="{{lessButtonCN}}" disabled="disabled" data-event="less">Less</button>'
            +   '</li>'
            +   '<li class="{{moreCN}}">'
            +     '<span class="{{moreLabelCN}}"></span>'
            +     '<button type="button" class="{{moreButtonCN}}" disabled="disabled" data-event="more">Less</button>'
            +   '</li>'
            +   '<li class="{{explanationCN}}">'
            +     '<label for="explanation">Explain: </label>'
            +     '<input id="explanation" name="explanation" type="text" class="{{explanationInputCN}}" />'
            +   '</li>'
            +   '<li class="{{buttonsCN}}">'
            +     '<button type="button" class="{{buttonsClaimCN}}" data-event="ok">Claim</button>'
            +     '<button type="button" class="{{buttonsCancelCN}}" data-event="cancel">Cancel</button>'
            +   '</li>'
            + '</ul>'

    });

    Y.Bridge.Claim = Claim;

}, "0", { requires: ["widget", "mustache"] });
