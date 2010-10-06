YUI.add("bar", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Bar = Y.Base.create("bar", Y.Widget, [], {

        initializer: function() {
            this.publish("claim");
            this.publish("quit");
            this.addTarget(this.get("host"));
        },

        renderUI: function() {
            this._renderBar();
        },

        _renderBar: function() {
            var html = Y.mustache(Bar.BAR_TEMPLATE, Bar);
            this.get("contentBox").setContent(html);
        },

        bindUI: function() {
            this._uiHandleButtonEvents();
            this.after("quitEnabledChange", this._afterQuitEnabledChange);
            this.after("claimEnabledChange", this._afterClaimEnabledChange);
        },

        _afterQuitEnabledChange: function(event) {
            this._uiSyncQuitEnabled(event.newVal);
        },

        _uiSyncQuitEnabled: function(quitEnabled) {
            this._uiToggleButton(DOT + Bar.C_QUIT, quitEnabled);
        },

        _afterClaimEnabledChange: function(event) {
            this._uiSyncClaimEnabled(event.newVal);
        },

        _uiSyncClaimEnabled: function(claimEnabled) {
            this._uiToggleButton(DOT + Bar.C_CLAIM, claimEnabled);
        }

    }, {

        ATTRS: {

            host: {

            },

            quitEnabled: {
                value: false
            },

            claimEnabled: {
                value: false
            }

        },

        C_BUTTON:        getClassName("bar", "button"),
        C_BUTTONS:       getClassName("bar", "buttons"),
        C_BUTTON_BUTTON: getClassName("bar", "button", "button"),
        C_CLAIM:         getClassName("bar", "claim"),
        C_QUIT:          getClassName("bar", "quit"),

        BAR_TEMPLATE: ''
            + '<ul class="{{C_BUTTONS}}">'
            +   '<li class="{{C_BUTTON}}">'
            +     '<button type="button" class="{{C_BUTTON_BUTTON}} {{C_CLAIM}}" disabled="disabled" data-event="claim">Claim</button>'
            +   '</li>'
            +   '<li class="{{C_BUTTON}}">'
            +     '<button type="button" class="{{C_BUTTON_BUTTON}} {{C_QUIT}}" disabled="disabled" data-event="quit">Quit</button>'
            +   '</li>'
            + '</ul>'

    });

    Y.augment(Bar, Y.Bridge.UiHelper);

    Y.Bridge.Bar = Bar;

}, "0", { requires: ["widget", "mustache"] });
