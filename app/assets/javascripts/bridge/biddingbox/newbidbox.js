YUI.add("newbidbox", function(Y){

    var NewBidBox = Y.Base.create("newbidbox", Y.Widget, [], {
        
        renderUI: function () {
            this._renderNewBidBox();
            this._renderLevels();
            this._renderSuits();
        },

        syncUI: function () {
            this._syncContract(this.get("contract"));
        },

        bindUI: function () {
            this.after("contractChange", this._afterContractChange);
            this._levelWidget.after("levelSelected", this._afterLevelSelected, this);
            this._suitWidget.after("suitSelected", this._afterSuitSelected, this);
        },

        _afterContractChange: function (event) {
            this._syncContract(event.newVal);
        },

        _afterLevelSelected: function (event, level) {
            this._level = level;
            if (level == this._minLevel) {
                this._suitWidget.set("minSuit", this._minSuit);
            } else {
                this._suitWidget.set("minSuit", Y.Bridge.CONTRACT_SUITS[0]);
            }
        },

        _afterSuitSelected: function (event, suit) {
            this._newBidSelected(Y.Bridge.makeContract(this._level, suit));
        },

        _syncContract: function (contract) {
            this._calcMinBid(contract);
            this._levelWidget.set("minLevel", this._minLevel);
            this._suitWidget.set("minSuit", undefined);
        },

        _renderLevels: function () {
            this._levelWidget = new Y.Bridge.NewBidBoxLevels().render(this.get("contentBox"));
        },

        _renderSuits: function () {
            this._suitWidget = new Y.Bridge.NewBidBoxSuits().render(this.get("contentBox"));
        },

        _calcMinBid: function (contract) {
            if (! contract) {
                this._minLevel = Y.Bridge.LEVELS[0];
                this._minSuit = Y.Bridge.CONTRACT_SUITS[0];
                return;
            }
            var cs = Y.Bridge.CONTRACT_SUITS,
                level = Y.Bridge.parseLevel(contract),
                suit = Y.Bridge.parseSuit(contract),
                isNT = cs.indexOf(suit) + 1 == cs.length;

            this._minLevel = level + isNT;
            this._minSuit = isNT ? cs[0] : cs[cs.indexOf(suit) + 1];
        },

        _newBidSelected: function (bid) {
            this._levelWidget.resetSelected();
            this._fireBidEvent(bid);
        },

        _fireBidEvent: function (bid) {
            this.fire("bid", bid);
        },

        _renderNewBidBox: function () {
            // Extra rendering stuff
            
        }

    }, {
        ATTRS: {
            
            contract: {
                value: undefined,
                setter: function (contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            }
            
        }
    });

    Y.namespace("Bridge").NewBidBox = NewBidBox;

}, "0", { requires: ["newbidboxlevels", "newbidboxsuits"] });
