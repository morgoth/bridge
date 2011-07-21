YUI.add("alertbox", function(Y){

    var AlertBox = Y.Base.create("alertbox", Y.Widget, [], {

        ALERT_INPUT_TEMPLATE: '<input type="text" />',

        renderUI: function () {
            this._renderAlertToggle();
            this._renderAlertInput();
        },

        _renderAlertInput: function () {
            this._alertInput = this.get("contentBox").appendChild(this.ALERT_INPUT_TEMPLATE);
        },

        _renderAlertToggle: function () {
            this._alertToggle = new Y.ButtonToggle({ label: "Alert" });
            this._alertToggle.render(this.get("contentBox"));
        },

        bindUI: function () {
            this._alertToggle.after("selectedChange", this._afterAlertTogglePress, this);
        },

        _afterAlertTogglePress: function (event) {
            var selected = !!event.newVal;

            this.set("alert", selected);
            this._syncAlertInput(selected);
        },

        syncUI: function () {
            this._syncAlertInput(this.get("alert"));
            this._syncAlertToggle(this.get("alert"));
        },

        _syncAlertInput: function (alert) {
            if (alert) {
                this._alertInput.show();
            } else {
                this._alertInput.hide();
            }
        },

        _syncAlertToggle: function (alert) {
            this._alertToggle.set("selected", +alert);
        },

        resetUI: function () {
            this.set("alert", false);
            this.set("alertMsg", "");
            this.syncUI();
        },

        getAlert: function () {
            var result = {};

            Y.each(["alert", "alertMsg"], function (name) {
                result[name] = this.get(name);
            }, this);

            return result;
        },

        getAlertAndResetUI: function () {
            var result = this.getAlert();

            this.resetUI();

            return result;
        }

    }, {

        ATTRS: {

            alertMsg: {
                validator: Y.Lang.isString,
                getter: function () {
                    return this._alertInput.get("value");
                },
                setter: function (text) {
                    this._alertInput.set("value", text);
                }
            },

            alert: {
                value: false,
                validator: Y.Lang.isBoolean
            }

        }

    });

    Y.namespace("Bridge").AlertBox = AlertBox;

}, "0", { requires: ["node", "gallery-button-toggle"] });
