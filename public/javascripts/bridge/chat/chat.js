YUI.add("chat", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    function Chat() {
        Chat.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Chat, Y.Widget, {

        initializer: function() {
            this._initializePoll();
            this.poll.start();
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
            this.after("nameChange", this._afterNameChange);
            this.after("disabledChange", this._afterDisabledChange);
        },

        _afterNameChange: function(event) {
            this._uiSyncName(event.newVal);
        },

        _afterDisabledChange: function(event) {
            this._uiSyncDisabled(event.newVal);
        },

        _onFormSubmit: function(event) {
            var disabled = this.get("disabled"),
                name = this.get("name"),
                message = this._uiGetMessage(),
                channelMessagesPath = Y.mustache(Chat.CHANNEL_MESSAGES_PATH, {
                    channelId: this.get("channelId")
                });

            event.preventDefault();

            if(!disabled && (message.length > 0)) {
                this.poll.stop();
                // actually stops polling (previous stop can kill
                // active transaction only) - weird behaviour
                Y.later(0, this, function() {
                    this.poll.stop();
                });

                this.disable();

                Y.io(channelMessagesPath, {
                    data: "message[body]=" + encodeURIComponent(message),
                    method: "POST",
                    on: {
                        success: Y.bind(this._onRequestSuccess, this),
                        failure: Y.bind(this._onRequestFailure, this)
                    }
                });

                this._uiAddMessage(name, message);
                this._uiClearMessage();
            }
        },

        _onRequestSuccess: function() {
            this.poll.start();
            this.enable();
        },

        _onRequestFailure: function(id, response) {
            Y.log(response);
            alert("Error: communication problem occured, page reload might be required.");
            this.poll.start();
            this.enable();
        },

        syncUI: function() {
            this._uiSyncName(this.get("name"));
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

        _uiSyncName: function(name) {
            var formNode,
                contentBox = this.get("contentBox");
            formNode = contentBox.one(DOT + Chat.C_FORM);

            if(Y.Lang.isString(name)) {
                formNode.removeClass(Chat.C_FORM_DISABLED);
                this.enable();
            } else {
                formNode.addClass(Chat.C_FORM_DISABLED);
                this.disable();
            }
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

        _initializePoll: function() {
            var timeout = this.get("pollTimeout"),
                channelMessagesPath = Y.mustache(Chat.CHANNEL_MESSAGES_PATH, {
                    channelId: this.get("channelId")
                });

            this.isFirstPoll = true;
            this.poll = Y.io.poll(timeout, channelMessagesPath, {
                method: "GET",
                headers: {},
                on: {
                    modified: Y.bind(this._onPollModified, this)
                }
            });
        },

        _onPollModified: function(id, o) {
            var position,
                name = this.get("name"),
                messages = Y.JSON.parse(o.responseText);

            Y.each(messages, function(message) {
                if(this.isFirstPoll || (name !== message.name)) {
                    this._uiAddMessage(message.name, message.body);
                }
            }, this);

            position = o.getResponseHeader("Current-Position");

            if(position) {
                this.poll.get("ioConfig").headers["Last-Position"] = position;
                Y.log(position);
            }

            this.isFirstPoll = false;
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

            name: {

            },

            channelId: {
                setter: parseInt
            },

            pollTimeout: {
                value: 5000,
                validator: Y.Lang.isNumber
            }

        },

        C_MESSAGES:      getClassName("chat", "messages"),
        C_MESSAGES_NAME: getClassName("chat", "messages", "name"),
        C_MESSAGES_BODY: getClassName("chat", "messages", "body"),
        C_FORM:          getClassName("chat", "form"),
        C_FORM_DISABLED: getClassName("chat", "form", "disabled"),
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

}, "0", { requires: ["widget", "mustache", "gallery-io-poller", "json"] });
