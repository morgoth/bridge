YUI.add("button", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Button = Y.Base.create("button", Y.Widget, [], {

        CONTENT_TEMPLATE: '<button type="button"></button>',

        renderUI: function() {

        },

        bindUI: function() {
            this.after("labelChange", this._afterLabelChange);
            this.after("disabledChange", this._afterDisabledChange);
            this.get("contentBox").after("click", this._afterContentBoxClicked, this);
        },

        _afterLabelChange: function(event) {
            this._uiSyncLabel(event.newVal);
        },

        _afterDisabledChange: function(event) {
            this._uiSyncDisabled(event.newVal);
        },

        _afterContentBoxClicked: function(event) {
            this.fire("clicked", this.get("name"));
        },

        syncUI: function() {
            this._uiSyncLabel(this.get("label"));
        },

        _uiSyncLabel: function(label) {
            this.get("contentBox").setContent(label);
        },

        _uiSyncDisabled: function(disabled) {
            if(disabled) {
                this.get("contentBox").setAttribute("disabled", "disabled");
            } else {
                this.get("contentBox").removeAttribute("disabled");
            }
        }

    }, {
        ATTRS: {

            name: {
                value: "button"
            },

            label: {
                value: "Button"
            }

        }
    });

    Y.Bridge.Button = Button;

}, "0", { requires: ["widget"] });
