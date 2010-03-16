YUI.add("hand", function(Y) {

    Y.namespace("Bridge");

    function Hand() {
        Hand.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Hand, Y.Widget, {

        initializer: function() {
            var host = this.get("host");

            this.publish("join");
            this.publish("quit");
            this.addTarget(host);
        },

        renderUI: function() {
            this._renderMainTemplate();
        },

        _renderMainTemplate: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Hand.MAIN_TEMPLATE, {
                direction: this.get("direction"),
                directionCN: this.getClassName("direction"),
                joinCN: this.getClassName("join"),
                quitCN: this.getClassName("quit"),
                name: this.get("name"),
                nameCN: this.getClassName("name")
            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("cardsChange", this._afterCardsChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("nameChange", this._afterNameChange);
            this.after("disabledChange", this._afterDisabledChange);
            this.after("joinEnabledChange", this._afterJoinEnabledChange);
            this.after("quitEnabledChange", this._afterQuitEnabledChange);
            contentBox.delegate("click", Y.bind(this._onButtonClick, this), "button");
        },

        _afterJoinEnabledChange: function(event) {
            this._uiSyncJoin(event.newVal);
        },

        _afterQuitEnabledChange: function(event) {
            this._uiSyncQuit(event.newVal);
        },

        _onButtonClick: function(event) {
            var eventName,
                target = event.target;

            eventName = target.getAttribute("data-event");

            this.fire(eventName);
        },

        syncUI: function() {
            this._uiSyncJoin();
            this._uiSyncQuit();
        },

        _afterCardsChange: function(event) {
            // this._uiSetCards(event.newVal);
        },

        _afterDirectionChange: function(event) {
            // this._uiSetDirection(event.newVal);
        },

        _afterNameChange: function(event) {
            this._uiSetName(event.newVal);
        },

        _uiSyncJoin: function() {
            var joinNode,
                contentBox = this.get("contentBox"),
                joinEnabled = this.get("joinEnabled"),
                name = this.get("name");
            joinNode = contentBox.one("." + this.getClassName("join"));

            joinNode.set("disabled", "disabled");
            if(!name && joinEnabled) {
                joinNode.removeAttribute("disabled");
            }
        },

        _uiSyncQuit: function() {
            var quitNode,
                contentBox = this.get("contentBox"),
                quitEnabled = this.get("quitEnabled"),
                name = this.get("name");
            quitNode = contentBox.one("." + this.getClassName("quit"));

            quitNode.set("disabled", "disabled");
            if(name && quitEnabled) {
                quitNode.removeAttribute("disabled");
            }
        },

        _uiSetName: function(name) {
            var nameNode,
                contentBox = this.get("contentBox");

            nameNode = contentBox.one("." + this.getClassName("name"));
            nameNode.set("innerHTML", name);
            this._uiSyncJoin();
            this._uiSyncQuit();
        },

        _afterDisabledChange: function(event) {
            // this._uiSetDisabled(event.newVal);
        }

    }, {

        NAME: "hand",

        ATTRS: {

            host: {
            },

            direction: {
            },

            name: {
                setter: function(value) {
                    return value ? value : "";
                }
            },

            cards: {
                value: []
            },

            joinEnabled: {
                value: false
            },

            quitEnabled: {
                value: false
            }

        },

        MAIN_TEMPLATE: '' +
            '<div class="{{directionCN}}">{{direction}}</div>' +
            '<div class="{{nameCN}}">{{name}}</div>' +
            '<button type="button" class="{{joinCN}}" data-event="join">Join</button>' +
            '<button type="button" class="{{quitCN}}" data-event="quit">Quit</button>'

    });

    Y.Bridge.Hand = Hand;

}, "0", { requires: ["widget", "mustache"] });
