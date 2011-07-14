YUI.add("passbox", function (Y) {

    // Fires pressed button name (pass, x, xx)
    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [Y.WidgetChild], {

        renderUI: function () {
            this._renderPassBox();
        },

        syncUI: function () {
            this._syncEnabled(this.get("enabled"));
        },

        _syncEnabled: function (enabled) {
            this.each(function (button) {
                button.set("enabled", this.get("enableButtons." + button.get("name")));
            }, this);
        },

        bindUI: function () {
            this.after("button:press", this._afterButtonPress);
            this.after("enabledChange", this._afterEnabledChange);
        },

        _afterButtonPress: function (event) {
            this.fire(event.target.get("name"));
        },

        _afterEnabledChange: function (event) {
            this._syncEnabled(event.newVal);
        },

        _renderPassBox: function () {
            this._this.add([
                { label: "pass", name: "pass" },
                { label: "x", name: "x" },
                { label: "xx", name: "xx" }
            ]);
        }

    }, {

        NAME: "passbox",

        ATTRS: {

            defaultChildType: {
                value: Y.Button
            },

            label: {
                value: ""
            },

            enableButtons: {
                value: {
                    "pass": true,
                    "x": false,
                    "xx": true
                }
            }

        }

    });

    Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
