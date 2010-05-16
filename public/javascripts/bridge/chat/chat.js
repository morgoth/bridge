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
        },

        _onFormSubmit: function(event) {
            var message = this._uiGetMessage(),
                channelMessagesPath = Y.mustache(Chat.CHANNEL_MESSAGES_PATH, {
                    channelId: this.get("channelId")
                });

            event.preventDefault();

            if(message.length > 0) {
                this.poll.stop();
                // actually stops polling (previous stop can kill active
                // transaction only) - weird behaviour
                Y.later(0, this, function() {
                    this.poll.stop();
                });

                Y.io(channelMessagesPath, {
                    data: "message[body]=" + encodeURIComponent(message),
                    method: "POST",
                    on: {
                        success: Y.bind(this._onRequestSuccess, this),
                        failure: Y.bind(this._onRequestFailure, this)
                    }
                });

                // this._uiAddMessage("qoobaa", message);
                // this._uiClearMessage();
            }
        },

        _onRequestSuccess: function() {
            this.poll.start();
        },

        _onRequestFailure: function(id, response) {
            Y.log(response);
            alert("Error: communication problem occured, page reload might be required.");
            this.poll.start();
        },

        syncUI: function() {

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
        },

        _initializePoll: function() {
            var timeout = this.get("pollTimeout"),
                channelMessagesPath = Y.mustache(Chat.CHANNEL_MESSAGES_PATH, {
                    channelId: this.get("channelId"),
                    position: this.get("position")
                });

            this.poll = Y.io.poll(timeout, channelMessagesPath, {
                method: "GET",
                on: {
                    modified: Y.bind(this._onPollModified, this),
                    failure: Y.bind(this._onPollFailure, this)
                }
            });
        },

        _onPollModified: function(id, o) {
            var messages = Y.JSON.parse(o.responseText);

            Y.each(messages, function(message) {
                this._uiAddMessage(message.name, message.body);
                this.set("position", message.position);
            }, this);

            // this.poll.stop();
            // this._initializePoll();
            // this.poll.start();
        },

        _onPollFailure: function(id, o) {
            Y.log(o);
        }

    }, {

        NAME: "chat",

        ATTRS: {

            channelId: {
                setter: parseInt
            },

            position: {
                setter: parseInt,
                value: 1
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
        C_FORM_INPUT:    getClassName("chat", "form", "input"),
        C_FORM_SUBMIT:   getClassName("chat", "form", "submit"),

        CHANNEL_MESSAGES_PATH: '/ajax/channels/{{channelId}}/messages.json{{#position}}?position={{position}}{{/position}}',

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

}, "0", { requires: ["widget", "mustache", "gallery-io-poller"] });
