YUI.add("alertbox", function(Y){

    var AlertBox = Y.Base.create("alertbox", Y.Widget, [], {

        ALERTINPUT_TEMPLATE:  '<input type="text" name="alertMsg" value=""/>',

        renderUI: function () {
            this._renderAlertToggle();
            this._renderAlertInput();
        },

        syncUI: function () {
            this._syncAlertInput(this.get("alert"));
            this._syncAlertToggle(this.get("alert"));
        },

        bindUI: function () {
            this._alertToggle.after("selectedChange", this._afterAlertTogglePress, this);
        },

        resetUI: function () {
            this.set("alert", false);
            this.set("alertMsg", "");
            this.syncUI();
        },

        getAlert: function () {
            var res = {};
            Y.each(["alert", "alertMsg"], function (name) {
                res[name] = this.get(name);
            }, this);
            return res;
        },

        getAlertAndResetUI: function () {
            var res = this.getAlert();
            this.resetUI();
            return res;
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

        _renderAlertInput: function () {
            this._alertInput = Y.Node.create(this.ALERTINPUT_TEMPLATE);
            this.get("contentBox").append(this._alertInput);
        },

        _renderAlertToggle: function () {
            this._alertToggle = new Y.ButtonToggle({ label: "alert" });
            this._alertToggle.render(this.get("contentBox"));
        },

        _afterAlertTogglePress: function (event) {
            var selected = !!event.newVal;
            this.set("alert", selected);
            this._syncAlertInput(selected);
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
