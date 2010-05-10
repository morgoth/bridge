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

            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            contentBox.delegate("click", Y.bind(this._onButtonClick, this), "button[data-event]");
        },

        _onButtonClick: function(event) {
            var eventName = event.target.getAttribute("data-event"),
                eventArgument = event.target.getAttribute("data-event-argument");

            this.fire(eventName, [eventArgument]);
        },

        syncUI: function() {

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

            tricks: {

            },

            name: {

            }

        },

        CLAIM_PREVIEW_TEMPLATE: ''
            + '<ul>'
            +   '<li class="{{buttonsCN}}">'
            +     '<button type="button" class="{{buttonsAcceptCN}}" data-event="accept">Accept</button>'
            +     '<button type="button" class="{{buttonsRejectCN}}" data-event="reject">Reject</button>'
            +     '<button type="button" class="{{buttonsCancelCN}}" data-event="reject">Cancel</button>'
            +   '</li>'
            + '</ul>'

    });

    Y.Bridge.ClaimPreview = ClaimPreview;

}, "0", { requires: ["widget", "mustache"] });
