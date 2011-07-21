YUI.add("passbox", function (Y) {

    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderButtons();
        },

        _renderButtons: function () {
            var buttonNames = ["PASS", "X", "XX"];

            this.add([{ label: "Pass" }, { label: "Dbl" }, { label: "Rdbl" }]);
            // Adding names and css classes
            this.each(function (button, i) {
                var className = this.getClassName("modifier", buttonNames[i].toLowerCase());

                button.addAttr("name", {
                    value: buttonNames[i],
                    writeOnce: true
                });
                // adding css class: "passbox-modifier-{button_name}"
                // FIXME: class gets added before yui3-button-content. Fix it or add it to boundingBox
                button.get("contentBox").addClass(className);
            }, this);
        },

        syncUI: function () {
            this._syncEnabledButtons(this.get("enabledButtons"));
        },

        _syncEnabledButtons: function (enabledButtons) {
            this.each(function (button, i) {
                button.set("enabled", enabledButtons[button.get("name")]);
            }, this);
        },

        bindUI: function () {
            this.after("button:press", this._afterButtonPress);
            this.after("enabledButtonsChange", this._afterEnabledButtonsChange);
        },

        _afterButtonPress: function (event) {
            this.fire("bid", event.target.get("name"));
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
