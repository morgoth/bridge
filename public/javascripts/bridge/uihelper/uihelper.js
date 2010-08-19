YUI.add("uihelper", function(Y) {

    Y.namespace("Bridge");

    function UiHelper() {

    };

    UiHelper.prototype = {

        _uiSetContent: function(node, value) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            textNode && textNode.setContent(value);
        },

        _uiSetValue: function(node, value) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            textNode && textNode.set("value", value);
        },

        _uiGetValue: function(node) {
            var textNode,
                contentBox = this.get("contentBox");
            textNode = contentBox.one(node);

            return textNode && textNode.get("value");
        },

        _uiToggleButton: function(node, enabled) {
            var buttonNode,
                contentBox = this.get("contentBox"),
                className = this.getClassName("button", "disabled");
            buttonNode = contentBox.one(node);

            if(enabled) {
                buttonNode && buttonNode.removeClass(className).removeAttribute("disabled");
            } else {
                buttonNode && buttonNode.addClass(className).setAttribute("disabled", "disabled");
            }
        }

    };

    Y.Bridge.UiHelper = UiHelper;

}, "", { requires: ["base", "node"] });
