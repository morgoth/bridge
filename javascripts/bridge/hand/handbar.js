YUI.add("handbar", function (Y) {

    var HandBar = Y.Base.create("handbar", Y.Widget, [], {

        renderUI: function () {
            this._renderBar();
        },

        _renderBar: function () {
            this._directionNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("direction"));
            this._nameNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("name"));
        },

        bindUI: function () {
            this.after("activeChange", this._afterActiveChange);
            this.after("directionChange", this._afterDirectionChange);
            this.after("nameChange", this._afterNameChange);
            this.get("contentBox").on("click", this._onContentBoxClick, this);
        },

        _afterActiveChange: function (event) {
            this._syncActive(event.newVal);
        },

        _afterDirectionChange: function (event) {
            this._syncDirection(event.newVal);
        },

        _afterNameChange: function (event) {
            this._syncName(event.newVal);
        },

        _onContentBoxClick: function (event) {
            if (this.get("disabled") && this.get("userId")) {
                this.fire("join", [this.get("direction")]);
            }
        },

        syncUI: function () {
            this._syncDirection(this.get("direction"));
            this._syncName(this.get("name"));
            this._syncActive(this.get("active"));
        },

        _syncDirection: function (direction) {
            this._directionNode.setContent(direction);
        },

        _syncName: function (name) {
            this._nameNode.setContent(name);
        },

        _syncActive: function (active) {
            if (active) {
                this.get("contentBox").addClass(this.getClassName("bar", "active"));
            } else {
                this.get("contentBox").removeClass(this.getClassName("bar", "active"));
            }
        }

    }, {

        ATTRS: {

            direction: {
                value: "",
                validator: Y.Lang.isString
            },

            name: {
                value: "",
                validator: Y.Lang.isString
            },

            active: {
                value: false,
                validator: Y.Lang.isBoolean
            }

        }

    });

    Y.namespace("Bridge").HandBar = HandBar;

}, "", { requires: ["widget"] });
