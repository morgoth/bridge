YUI.add("passbox", function (Y) {

    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [], {

        _buttonNames: ["PASS", "X", "XX"],

        renderUI: function () {
            this._renderButtons();
        },

        _renderButtons: function () {
            this.add([{ label: "Pass" }, { label: "Dbl" }, { label: "Rdbl" }]);
        },

        syncUI: function () {
            this._syncEnabledButtons(this.get("enabledButtons"));
        },

        _syncEnabledButtons: function (enabledButtons) {
            this.each(function (button, i) {
                button.set("enabled", enabledButtons[this._buttonNames[i]]);
            }, this);
        },

        bindUI: function () {
            this.after("button:press", this._afterButtonPress);
            this.after("enabledButtonsChange", this._afterEnabledButtonsChange);
        },

        _afterButtonPress: function (event) {
            var i = event.target.get("index");

            this.fire("bid", this._buttonNames[i]);
        },

        _afterEnabledButtonsChange: function (event) {
            this._syncEnabledButtons(event.newVal);
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.Button
            },

            enabledButtons: {
                value: {
                    PASS: true,
                    X: false,
                    XX: true
                }
            }

        }

    });

    Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
