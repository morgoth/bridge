YUI.add("uihelper", function(Y) {

    Y.namespace("Bridge");

    function UiHelper() {

    };

    UiHelper.prototype = {

        _uiSetContent: function(node, value) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            textNode.setContent(value);
        },

        _uiSetValue: function(node, value) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            textNode.set("value", value);
        },

        _uiGetValue: function(node) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            return textNode.get("value");
        },

        _uiToggleButton: function(node, enabled) {
            var buttonNode,
                contentBox = this.get("contentBox"),
                disabledClassName = this.getClassName("button", "disabled"),
                enabledClassName = this.getClassName("button", "enabled");
            buttonNode = contentBox.one(node);

            if(enabled) {
                buttonNode.replaceClass(disabledClassName, enabledClassName).removeAttribute("disabled");
            } else {
                buttonNode.replaceClass(enabledClassName, disabledClassName).setAttribute("disabled", "disabled");
            }
        }

    };

    Y.Bridge.UiHelper = UiHelper;

}, "", { requires: ["base", "node"] });
