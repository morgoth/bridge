YUI.add("claimpreview", function(Y) {

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

            html = Y.mustache(ClaimPreview.CLAIM_PREVIEW_TEMPLATE, {
                labelsCN:      this.getClassName("labels"),
                nameCN:        this.getClassName("name"),
                tricksCN:      this.getClassName("tricks"),
                totalCN:       this.getClassName("total"),
                explanationCN: this.getClassName("explanation"),
                buttonsCN:     this.getClassName("buttons"),
                acceptCN:      this.getClassName("accept"),
                rejectCN:      this.getClassName("reject"),
                cancelCN:      this.getClassName("cancel")
            });

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
            this._uiSetText("." + this.getClassName("name"), event.newVal);
        },

        _afterTricksChange: function(event) {
            this._uiSetText("." + this.getClassName("tricks"), event.newVal);
        },

        _afterTotalChange: function(event) {
            this._uiSetText("." + this.getClassName("total"), event.newVal);
        },

        _afterExplanationChange: function(event) {
            this._uiSetText("." + this.getClassName("explanation"), event.newVal);
        },

        _afterAcceptEnabledChange: function(event) {
            this.uiToggleButton("accept", event.newVal);
        },

        _afterRejectEnabledChange: function(event) {
            this.uiToggleButton("reject", event.newVal);
        },

        _afterCancelEnabledChange: function(event) {
            this.uiToggleButton("cancel", event.newVal);
        },

        _onButtonClick: function(event) {
            var eventName = event.target.getAttribute("data-event"),
                eventArgument = event.target.getAttribute("data-event-argument");

            this.fire(eventName, [eventArgument]);
        },

        syncUI: function() {

        },

        _uiSetText: function(node, value) {
            var textNode, textTemplate, html,
                replacements = {},
                strings = this.get("strings"),
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);
            textTemplate = strings[text + "Template"] || ("{" + text + "}");
            replacements[text] = value;

            html = Y.substitute(textTemplate, replacements);
            textNode.set("innerHTML", html);
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

        NAME: "claimpreview",

        ATTRS: {

            host: {

            },

            name: {

            },

            tricks: {

            },

            total: {

            },

            explanation: {

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

        CLAIM_PREVIEW_TEMPLATE: ''
            + '<ul>'
            +   '<li class="{{labelsCN}}">'
            +     '<span class="{{nameCN}}"></span>'
            +     '<span class="{{tricksCN}}"></span>'
            +     '<span class="{{totalCN}}"></span>'
            +     '<span class="{{explanationCN}}"></span>'
            +   '</li>'
            +   '<li class="{{buttonsCN}}">'
            +     '<button type="button" class="{{acceptCN}}" data-event="accept">Accept</button>'
            +     '<button type="button" class="{{rejectCN}}" data-event="reject">Reject</button>'
            +     '<button type="button" class="{{cancelCN}}" data-event="reject">Cancel</button>'
            +   '</li>'
            + '</ul>'

    });

    Y.Bridge.ClaimPreview = ClaimPreview;

}, "0", { requires: ["widget", "mustache"] });
