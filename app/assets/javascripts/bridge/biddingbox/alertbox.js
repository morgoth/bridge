YUI.add("alertbox", function (Y) {

    var AlertBox = Y.Base.create("alertbox", Y.Widget, [], {

        renderUI: function () {
            this._renderAlertToggle();
            this._renderAlertInput();
        },

        _renderAlertInput: function () {
            this._alertInput = this.get("contentBox").appendChild('<input type="text">');
        },

        _renderAlertToggle: function () {
            this._alertToggle = new Y.ButtonToggle({ label: "Alert" }).render(this.get("contentBox"));
        },

        bindUI: function () {
            this._alertToggle.after("selectedChange", this._afterAlertTogglePress, this);
            this._alertInput.on("valueChange", this._onAlertInputValueChange, this);
            this.after("alertMessageChange", this._afterAlertMessageChange);
            this.after("alertChange", this._afterAlertChange);
        },

        _afterAlertTogglePress: function (event) {
            var selected = !!event.newVal;

            this.setAttrs({ alert: selected, alertMessage: selected ? this.get("alertMessage") : "" });
        },

        _onAlertInputValueChange: function (event) {
            this.setAttrs({ alert: event.newVal !== "", alertMessage: event.newVal });
        },

        _afterAlertMessageChange: function (event) {
            this._syncAlertMessage(event.newVal);
        },

        _afterAlertChange: function (event) {
            this._syncAlert(event.newVal);
        },

        syncUI: function () {
            this._syncAlert(this.get("alert"));
            this._syncAlertMessage(this.get("alertMessage"));
        },

        _syncAlert: function (alert) {
            this._alertToggle.set("selected", +alert);
        },

        _syncAlertMessage: function (alertMessage) {
            this._alertInput.set("value", alertMessage);
        }

    }, {

        ATTRS: {

            alertMessage: {
                value: "",
                validator: Y.Lang.isString
            },

            alert: {
                value: false,
                validator: Y.Lang.isBoolean
            }

        }

    });

    Y.namespace("Bridge").AlertBox = AlertBox;

}, "0", { requires: ["event-valuechange", "gallery-button-toggle"] });
