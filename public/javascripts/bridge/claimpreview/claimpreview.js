YUI.add("claimpreview", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT   = ".";

    Y.namespace("Bridge");

    function ClaimPreview() {
        ClaimPreview.superclass.constructor.apply(this, arguments);
    }

    Y.extend(ClaimPreview, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            if(host) {
                this.publish("accept");
                this.publish("reject");
                this.addTarget(host);
            }
        },

        renderUI: function() {
            this._renderClaimPreview();
        },

        _renderClaimPreview: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(ClaimPreview.CLAIM_PREVIEW_TEMPLATE, ClaimPreview);
            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("nameChange",          this._afterNameChange);
            this.after("tricksChange",        this._afterTricksChange);
            this.after("totalChange",         this._afterTotalChange);
            this.after("explanationChange",   this._afterExplanationChange);
            this.after("acceptEnabledChange", this._afterAcceptEnabledChange);
            this.after("rejectEnabledChange", this._afterRejectEnabledChange);
            this.after("cancelEnabledChange", this._afterCancelEnabledChange);

            contentBox.delegate("click", Y.bind(this._onButtonClick, this), "button[data-event]");
        },

        _afterNameChange: function(event) {
            this._uiSetName(event.newVal);
        },

        _afterTricksChange: function(event) {
            this._uiSetTricks(event.newVal);
        },

        _afterTotalChange: function(event) {
            this._uiSetTotal(event.newVal);
        },

        _afterExplanationChange: function(event) {
            this._uiSetExplanation(event.newVal);
        },

        _afterAcceptEnabledChange: function(event) {
            this._uiToggleButton(DOT + ClaimPreview.C_ACCEPT, event.newVal);
        },

        _afterRejectEnabledChange: function(event) {
            this._uiToggleButton(DOT + ClaimPreview.C_REJECT, event.newVal);
        },

        _afterCancelEnabledChange: function(event) {
            this._uiToggleButton(DOT + ClaimPreview.C_CANCEL, event.newVal);
        },

        _onButtonClick: function(event) {
            var eventName = event.target.getAttribute("data-event"),
                eventArgument = event.target.getAttribute("data-event-argument");

            this.fire(eventName, [eventArgument]);
        },

        syncUI: function() {

        },

        _uiSetName: function(name) {
            this._uiSetText(DOT + ClaimPreview.C_NAME, name + ":");
        },

        _uiSetTricks: function(tricks) {
            this._uiSetText(DOT + ClaimPreview.C_TRICKS, "I claim " + tricks.toString() + " more tricks.");
        },

        _uiSetTotal: function(total) {
            this._uiSetText(DOT + ClaimPreview.C_TOTAL, total.toString() + " total tricks for declarer.");
        },

        _uiSetExplanation: function(explanation) {
            this._uiSetText(DOT + ClaimPreview.C_EXPLANATION, explanation);
        },

        _uiSetText: function(node, value) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            textNode.set("innerHTML", value);
        },

        _uiToggleButton: function(node, enabled) {
            var buttonNode,
                contentBox = this.get("contentBox"),
                className = this.getClassName("button", "disabled");
            buttonNode = contentBox.one(node);

            if(enabled) {
                buttonNode.removeAttribute("disabled").removeClass(className);
            } else {
                buttonNode.setAttribute("disabled", "disabled").addClass(className);
            }
        },

        _validateTricks: function(tricks) {
            return Y.Lang.isNumber(tricks) && tricks >= 0 && tricks <= 13;
        },

        _validateTotal: function(total) {
            return Y.Lang.isNumber(total) && total >= 0 && total <= 13;
        }

    }, {

        NAME: "claimpreview",

        ATTRS: {

            host: {

            },

            name: {
                validator: Y.Lang.isString
            },

            tricks: {
                validator: "_validateTricks"
            },

            total: {
                validator: "_validateTotal"
            },

            explanation: {
                validator: Y.Lang.isString
            },

            acceptEnabled: {
                validator: Y.Lang.isBoolean
            },

            rejectEnabled: {
                validator: Y.Lang.isBoolean
            },

            cancelEnabled: {
                validator: Y.Lang.isBoolean
            }

        },

        C_LABELS:      getClassName("claimpreview", "labels"),
        C_NAME:        getClassName("claimpreview", "name"),
        C_TRICKS:      getClassName("claimpreview", "tricks"),
        C_TOTAL:       getClassName("claimpreview", "total"),
        C_EXPLANATION: getClassName("claimpreview", "explanation"),
        C_BUTTONS:     getClassName("claimpreview", "buttons"),
        C_ACCEPT:      getClassName("claimpreview", "accept"),
        C_REJECT:      getClassName("claimpreview", "reject"),
        C_CANCEL:      getClassName("claimpreview", "cancel"),

        CLAIM_PREVIEW_TEMPLATE: ''
            + '<ul>'
            +   '<li class="{{C_LABELS}}">'
            +     '<span class="{{C_NAME}}"></span>'
            +     '<span class="{{C_TRICKS}}"></span>'
            +     '<span class="{{C_TOTAL}}"></span>'
            +     '<span class="{{C_EXPLANATION}}"></span>'
            +   '</li>'
            +   '<li class="{{C_BUTTONS}}">'
            +     '<button type="button" class="{{C_ACCEPT}}" data-event="accept">Accept</button>'
            +     '<button type="button" class="{{C_REJECT}}" data-event="reject">Reject</button>'
            +     '<button type="button" class="{{C_CANCEL}}" data-event="reject">Cancel</button>'
            +   '</li>'
            + '</ul>'

    });

    Y.Bridge.ClaimPreview = ClaimPreview;

}, "0", { requires: ["widget", "mustache"] });
