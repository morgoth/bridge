YUI.add("chat", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    function Chat() {
        Chat.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Chat, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            if(host) {
                this.publish("message");
                this.addTarget(host);
            }
        },

        renderUI: function() {
            this._renderChat();
        },

        _renderChat: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Chat.CHAT_TEMPLATE, Chat);
            contentBox.setContent(html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            contentBox.one(DOT + Chat.C_FORM).on("submit", this._onFormSubmit, this);
            this.after("disabledChange", this._afterDisabledChange);
        },

        _onFormSubmit: function(event) {
            var disabled = this.get("disabled"),
                message = this._uiGetMessage(),
                channelMessagesPath = Y.mustache(Chat.CHANNEL_MESSAGES_PATH, {
                    channelId: this.get("channelId")
                });

            event.preventDefault();

            if(!disabled && (message.length > 0)) {
                this.fire("message", [message]);

                this._uiClearMessage();
            }
        },

        _afterDisabledChange: function(event) {
            this._uiSyncDisabled(event.newVal);
        },

        _uiGetMessage: function() {
            var formInputNode,
                contentBox = this.get("contentBox");
            formInputNode = contentBox.one(DOT + Chat.C_FORM_INPUT);

            return formInputNode.get("value");
        },

        _uiClearMessage: function() {
            var formInputNode,
                contentBox = this.get("contentBox");
            formInputNode = contentBox.one(DOT + Chat.C_FORM_INPUT);

            formInputNode.set("value", "");
        },

        addMessage: function(name, body) {
            this._uiAddMessage(name, body);
        },

        _uiAddMessage: function(name, body) {
            var messagesNode, html,
                contentBox = this.get("contentBox");
            messagesNode = contentBox.one(DOT + Chat.C_MESSAGES);

            html = Y.mustache(Chat.MESSAGE_TEMPLATE, {
                name:            name,
                body:            body,
                C_MESSAGES_NAME: Chat.C_MESSAGES_NAME,
                C_MESSAGES_BODY: Chat.C_MESSAGES_BODY
            });

            messagesNode.append(html);

            Y.later(0, this, function() {
                var scrollHeight = messagesNode.get("scrollHeight"),
                    offsetHeight = messagesNode.get("offsetHeight");

                messagesNode.set("scrollTop", scrollHeight - offsetHeight);
            });
        },

        _uiSyncDisabled: function(disabled) {
            var formSubmitNode,
                contentBox = this.get("contentBox");
            formSubmitNode = contentBox.one(DOT + Chat.C_FORM_SUBMIT);

            if(disabled) {
                this._disableButton(formSubmitNode);
            } else {
                this._enableButton(formSubmitNode);
            }
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

        NAME: "chat",

        ATTRS: {

            host: {

            }

        },

        C_MESSAGES:      getClassName("chat", "messages"),
        C_MESSAGES_NAME: getClassName("chat", "messages", "name"),
        C_MESSAGES_BODY: getClassName("chat", "messages", "body"),
        C_FORM:          getClassName("chat", "form"),
        C_FORM_INPUT:    getClassName("chat", "form", "input"),
        C_FORM_SUBMIT:   getClassName("chat", "form", "submit"),

        CHANNEL_MESSAGES_PATH: '/ajax/channels/{{channelId}}/messages.json',

        CHAT_TEMPLATE: ''
            + '<dl class="{{C_MESSAGES}}">'
            + '</dl>'
            + '<form class="{{C_FORM}}">'
            +   '<input type="text" name="message" class="{{C_FORM_INPUT}}" autocomplete="off" />'
            +   '<input type="submit" value="Send message" class="{{C_FORM_SUBMIT}}" />'
            + '</form>',

        MESSAGE_TEMPLATE: ''
            + '<dt class="{{C_MESSAGES_NAME}}">'
            +   '{{name}}:'
            + '</dt>'
            + '<dd class="{{C_MESSAGES_BODY}}">'
            +   '{{body}}'
            + '</dd>'

    });

    Y.Bridge.Chat = Chat;

}, "0", { requires: ["widget", "mustache"] });
