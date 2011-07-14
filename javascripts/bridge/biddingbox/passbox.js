YUI.add("passbox", function (Y) {

    // Fires pressed button name (pass, x, xx)
    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderPassBox();
        },

        _renderPassBox: function () {
            this.add([
                { label: "Pass", name: "pass" },
                { label: "Dbl", name: "x" },
                { label: "Rdbl", name: "xx" }
            ]);
        },

        syncUI: function () {
            this._syncEnabledButtons(this.get("enabledButtons"));
        },

        _syncEnabledButtons: function (enabledButtons) {
            this.each(function (button) {
                button.set("enabled", enabledButtons[button.get("name")]);
            });
        },

        bindUI: function () {
            this.after("button:press", this._afterButtonPress);
            this.after("enabledButtonsChange", this._afterEnabledButtonsChange);
        },

        _afterButtonPress: function (event) {
            this.fire(event.target.get("name"));
        },

        _afterEnabledButtonsChange: function (event) {
            this._syncEnabledButtons(event.newVal);
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

            enabledButtons: {
                value: {
                    pass: true,
                    x: false,
                    xx: true
                }
            }

        }

    });

    Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
