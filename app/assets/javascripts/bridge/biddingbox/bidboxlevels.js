YUI.add("bidboxlevels", function(Y){

    var BidBoxLevels = Y.Base.create("bidboxlevels", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderBidBoxLevels();
        },

        syncUI: function () {
            this._syncMinLevel(this.get("minLevel"));
        },

        bindUI: function () {
            this.after("selectionChange", this._afterSelectionChange);
            this.after("minLevelChange", this._afterMinLevelChange);
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

        _renderBidBoxLevels: function () {
            Y.each(Y.Bridge.LEVELS, function (level) {
                this.add({ label: level.toString() });
            }, this);
        },

        _fireLevelEvent: function (level) {
            this.fire("levelSelected", level);
        }

    }, {

        ATTRS: {

            defaultChildType: {
                value: Y.ButtonToggle
            },

            minLevel: {
                // undefined -> no choice available
                value: undefined,
                setter: function (level) {
                    return (Y.Lang.isValue(level) && Y.Bridge.isLevel(level)) ? level : undefined;
                }
            }

        }

    });

    Y.namespace("Bridge").BidBoxLevels = BidBoxLevels;

}, "0", { requires: ["gallery-button-toggle", "gallery-button-group"] });
