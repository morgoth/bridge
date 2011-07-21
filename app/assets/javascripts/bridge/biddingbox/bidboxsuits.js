YUI.add("bidboxsuits", function(Y){

    var BidBoxSuits = Y.Base.create("bidboxsuit", Y.ButtonGroup, [], {

        renderUI: function () {
            this._renderBidBoxSuits();
        },

        syncUI: function () {
            this._syncMinSuit(this.get("minSuit"));
        },

        _syncMinSuit: function (minSuit) {
            var minIndex = Y.Bridge.CONTRACT_SUITS.indexOf(minSuit);
            if (!Y.Lang.isValue(minSuit)){
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

        _renderBidBoxSuits: function () {
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

    Y.namespace("Bridge").BidBoxSuits = BidBoxSuits;

}, "0", { requires: ["gallery-button", "gallery-button-toggle", "gallery-button-group"] });
