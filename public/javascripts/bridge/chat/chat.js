YUI.add("chat", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    function Chat() {
        Chat.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Chat, Y.Widget, {

        renderUI: function() {
            this._renderChat();
        },

        _renderChat: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Chat.CHAT_TEMPLATE, Chat);
            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            contentBox.one(DOT + Chat.C_FORM).on("submit", this._onFormSubmit, this);
        },

        _onFormSubmit: function(event) {
            event.preventDefault();
        },

        syncUI: function() {

        }

    }, {

        NAME: "chat",

        ATTRS: {

        },

        C_MESSAGES:      getClassName("chat", "messages"),
        C_MESSAGES_NAME: getClassName("chat", "messages", "name"),
        C_MESSAGES_TEXT: getClassName("chat", "messages", "text"),
        C_FORM:          getClassName("chat", "form"),
        C_FORM_INPUT:    getClassName("chat", "form", "input"),
        C_FORM_SUBMIT:   getClassName("chat", "form", "submit"),

        CHAT_TEMPLATE: ''
            + '<dl class="{{C_MESSAGES}}">'
            + '</dl>'
            + '<form class="{{C_FORM}}">'
            +   '<input type="text" name="message" class="{{C_FORM_INPUT}}" />'
            +   '<input type="submit" value="Send message" class="{{C_FORM_SUBMIT}}" />'
            + '</form>',

        MESSAGE_TEMPLATE: ''
            + '<dt class="{{C_MESSAGES_NAME}}">'
            +   '{{name}}'
            + '</dt>'
            + '<dd class="{{C_MESSAGES_TEXT}}">'
            +   '{{message}}'
            + '</dd>'

    });

    Y.Bridge.Chat = Chat;

}, "0", { requires: ["widget", "mustache"] });
