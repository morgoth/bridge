YUI.add("passbox", function (Y) {

    // Fires pressed button name (pass, x, xx)
    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderButtons();
        },

        _renderButtons: function () {
            // TODO: Tutaj jest problem. Podanie niezadeklarowanego atrybutu w konstruktorze nie działa. Działa jedynie instance.set("name", "pass"). Być może to nie powinno w ogóle działać i trzeba to rozwiązać inaczej
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
                    pass: true,
                    x: false,
                    xx: true
                }
            }

        }

    });

    Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
