YUI.add("newbidboxlevels", function(Y){

    var NewBidBoxLevels = Y.Base.create("newbidboxlevels", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderNewBidBoxLevels();
        },

        syncUI: function () {
            this._syncMinLevel(this.get("minLevel"));
        },

        bindUI: function () {
            this.after("selectionChange", this._afterSelectionChange);
            this.on("minLevelChange", this._afterMinLevelChange);
        },

        resetSelected: function () {
            this.each(function (child) {
                child.set("selected", 0);
            }, this);
        },

        _afterMinLevelChange: function (event) {
            this._syncMinLevel(event.newVal);
        },

        _syncMinLevel: function (minLevel) {
            if (! Y.Lang.isValue(minLevel)){
                minLevel = 8; // nah nah nah
            }
            this.each(function (child, i) {
                child.set("enabled", i + 1 >= minLevel);
            }, this);
        },

        _afterSelectionChange: function(event) {
            var button = event.newVal;
            if (Y.Lang.isValue(button)){
                this._fireLevelEvent(button.get("index") + 1);
            }
        },

        _renderNewBidBoxLevels: function () {
            Y.each(Y.Bridge.LEVELS, function (level) {
                var button = new Y.ButtonToggle({
                    label: level.toString()
                });
                this.add(button);
            }, this);
        },

        _fireLevelEvent: function (level) {
            this.fire("levelSelected", level);
        }

    }, {
        ATTRS: {

            minLevel: {
                // undefined -> no choice available
                value: undefined,
                setter: function (level) {
                    return (Y.Lang.isValue(level) && Y.Bridge.isLevel(level)) ? level : undefined;
                }
            }

        }
    });

    Y.namespace("Bridge").NewBidBoxLevels = NewBidBoxLevels;

}, "0", { requires: ["gallery-button-toggle", "gallery-button-group"] });
