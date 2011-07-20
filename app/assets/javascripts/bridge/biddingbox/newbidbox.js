YUI.add("newbidbox", function(Y){

    // FIXME: to nie są przypadkiem dwa widgety połączone w jeden? (dwa buttongroupy)
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
            this._bindLevels();
            this._bindSuits();
            this.after("levelChange", this._afterLevelChange);
            this.after("contractChange", this._afterContractChange);
        },

        resetUI: function () {
            // Uncheck level buttons
            this._levelWidget.each(function (button) {
                button.set("selected", 0);
            });
        },

        _syncLevels: function () {
            this._levelWidget.each(function (child) {
                child.set("enabled", child.get("level") >= this._minLevel);
            }, this);
        },

        _syncSuits: function (level) {
            var cs = Y.Bridge.CONTRACT_SUITS;
            if (level == this._minLevel) {
                // Enable only those higher than current min suit
                this._suitWidget.each(function (child) {
                    child.set("enabled", cs.indexOf(child.get("suit")) >= cs.indexOf(this._minSuit));
                }, this);
            } else if (! level) {
                // If level is not set, than suits are disabled.
                this._suitWidget.each(function (child) {
                    child.set("enabled", false);
                }, this);
            } else {
                // Level is set, and is > than minimum, so enable all
                this._suitWidget.each(function (child) {
                    child.set("enabled", true);
                }, this);
            }
        },

        _syncContract: function (contract) {
            this._calcMinBid(contract);
            this._syncLevels();
            this._syncSuits(this.get("level"));
        },

        _bindSuits: function () {
            this._suitWidget.after("button:press", function (event) {
                var suit = event.target.get("suit");
                this.set("suit", suit);
                this._newBidSelected();
            }, this);
        },

        _bindLevels: function () {
            this._levelWidget.after("selectionChange", function (event) {
                var button = event.newVal;
                if (Y.Lang.isValue(button)){
                    this.set("level", button.get("level"));
                } else {
                    // On toggle deselect
                    this.set("level", undefined);
                }
            }, this);
        },

        _afterContractChange: function (event) {
            this._syncContract(event.newVal);
        },

        _afterLevelChange: function (event) {
            this._syncSuits(event.newVal);
        },

        _renderLevels: function () {
            // Create levels toggle group
            var lw = this._levelWidget = new Y.ButtonGroup({
                alwaysSelected: true,
                label: ""
            });
            // Populate it with buttons
            Y.each(Y.Bridge.LEVELS, function (level) {
                var button = new Y.ButtonToggle({
                    label: level.toString()
                });
                // TODO: Setting undeclared attribute in constructor does not work
                button.set("level", level);
                lw.add(button);
            }, this);
            lw.render(this.get("contentBox"));
        },

        _renderSuits: function () {
            // Suits button group
            var sw = this._suitWidget = new Y.ButtonGroup({ label: "" });
            
            Y.each(Y.Bridge.CONTRACT_SUITS, function (suit) {
                var button = new Y.Button({ label: suit });
                button.set("suit", suit);
                sw.add(button);
            }, this);
            // Add as a child
            sw.render(this.get("contentBox"));
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

        _newBidSelected: function () {
            this._fireBidEvent();
        },

        _fireBidEvent: function () {
            this.fire("bid", Y.Bridge.makeContract(
                this.get("level"),
                this.get("suit")));
        },

        _renderNewBidBox: function () {
            // Extra rendering stuff
            
        }

    }, {
        ATTRS: {
            
            contract: {
                value: "",
                setter: function (contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            },
            
            level: {
                value: undefined,
                setter: function (level) {
                    return (Y.Lang.isValue(level) && Y.Bridge.isLevel(level)) ? level : undefined;
                }
            },
            
            suit: {
                value: "",
                setter: function (suit) {
                    return (Y.Lang.isValue(suit) && Y.Bridge.isContractSuit(suit)) ? suit : undefined;
                }
            }
            
        }
    });

    Y.namespace("Bridge").NewBidBox = NewBidBox;

}, "0", { requires: ["gallery-button", "gallery-button-toggle", "gallery-button-group"] });
