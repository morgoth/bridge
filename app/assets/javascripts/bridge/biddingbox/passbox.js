YUI.add("passbox", function (Y) {

    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [], {

        buttonNames: ["PASS", "X", "XX"],

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
                button.set("enabled", enabledButtons[this.buttonNames[i]]);
            }, this);
        },

        bindUI: function () {
            this.after("button:press", this._afterButtonPress);
            this.after("enabledButtonsChange", this._afterEnabledButtonsChange);
        },

        _afterButtonPress: function (event) {
            var index = event.target.get("index");

            this.fire("bid", this.buttonNames[index]);
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
                    PASS: false,
                    X: false,
                    XX: false
                }
            }

        }

    });

    Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
