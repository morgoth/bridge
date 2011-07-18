YUI.add("auctionbid", function (Y) {

    var AuctionBid = Y.Base.create("auctionbid", Y.Button, [], {

        bindUI: function () {
            this.constructor.superclass.bindUI.apply(this, arguments);
            this.after("bidChange", this._afterBidChange);
            this.after("directionChange", this._afterDirectionChange);
        },

        _afterBidChange: function (event) {
            this._syncBid(event.newVal);
        },

        _afterDirectionChange: function (event) {
            this._syncDirection(event.newVal, event.prevVal);
        },

        syncUI: function () {
            this.constructor.superclass.syncUI.apply(this, arguments);
            this._syncBid(this.get("bid"));
            this._syncDirection(this.get("direction"));
        },

        _syncBid: function (bid) {
            if (Y.Lang.isValue(bid)) {
                this.set("label", bid);
            } else {
                this.set("label", "");
            }
        },

        _syncDirection: function (newDirection, prevDirection) {
            if (newDirection) {
                this.get("boundingBox").addClass(this.getClassName(newDirection.toLowerCase()));
            }

            if (prevDirection) {
                this.get("boundingBox").removeClass(this.getClassName(prevDirection.toLowerCase()));
            }
        },

        _validateBid: function (bid) {
            return Y.Bridge.isContract(bid) || (bid === "PASS");
        }

    }, {

        ATTRS: {

            bid: {
                validator: "_validateBid"
            },

            direction: {
                validator: Y.Bridge.isDirection
            }

        }

    });

    Y.namespace("Bridge").AuctionBid = AuctionBid;

}, "0", { requires: ["gallery-button", "helpers"] });
