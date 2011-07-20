YUI.add("newbidboxsuits", function(Y){

    var NewBidBoxSuits = Y.Base.create("newbidboxsuit", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderNewBidBoxSuits();
        },

        syncUI: function () {
            this._syncMinSuit(this.get("minSuit"));
        },

        _syncMinSuit: function (minSuit) {
            var minIndex = Y.Bridge.CONTRACT_SUITS.indexOf(minSuit);
            if (! Y.Lang.isValue(minSuit)){
                minIndex = 5; // nah nah nah
            }
            this.each(function (button, i) {
                button.set("enabled", i >= minIndex);
            }, this);
        },

        bindUI: function () {
            this.after("minSuitChange", this._afterMinSuitChange);
            this.after("button:press", this._afterButtonPress);
        },

        _getButtonSuit: function (button) {
            return Y.Bridge.CONTRACT_SUITS[button.get("index")];
        },

        _afterMinSuitChange: function (event) {
            this._syncMinSuit(event.newVal);
        },

        _afterButtonPress: function (event) {
            this._fireSuitSelected(this._getButtonSuit(event.target));
        },

        _renderNewBidBoxSuits: function () {
            Y.each(Y.Bridge.CONTRACT_SUITS, function (suit) {
                var button = new Y.Button({ label: suit });
                this.add(button);
            }, this);
        },

        _newSuitSelected: function () {
            this._fireBidEvent();
        },

        _fireSuitSelected: function (suit) {
            this.fire("suitSelected", suit);
        },

        _renderNewBidBox: function () {
            // Extra rendering stuff
        }

    }, {
        ATTRS: {

            minSuit: {
                value: undefined,
                setter: function (suit) {
                    return (Y.Lang.isValue(suit) && Y.Bridge.isContractSuit(suit)) ? suit : undefined;
                }
            }

        }
    });

    Y.namespace("Bridge").NewBidBoxSuits = NewBidBoxSuits;

}, "0", { requires: ["gallery-button", "gallery-button-toggle", "gallery-button-group"] });
