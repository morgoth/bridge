YUI.add("bid-model-list", function (Y) {

    var BidList = Y.Base.create("bid-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Bid,

        board: function () {
            return this._board;
        },

        bids: function () {
            return Y.Array.map(this._items, function (bid) {
                return bid.getAttrs(["bid", "alert", "message"]);
            });
        },

        lastContract: function () {
            var contracts = Y.Array.filter(this._items, function (bid) {
                return bid.isContract();
            });

            return contracts[contracts.length - 1];
        },

        lastModifier: function () {
            var modifiers = Y.Array.filter(this._items, function (bid) {
                return bid.isModifier();
            });

            return modifiers[modifiers.length - 1];
        },

        firstBidWithSuitAndSide: function (suit, direction) {
            return Y.Array.find(this._items, function (bid) {
                return bid.suit() === suit && bid.isSameSide(direction);
            });
        },

        isCompleted: function () {
            if (this.size() > 3) {
                return Y.Array.every(this._items.slice(-3), function (bid) {
                    return bid.isPass();
                });
            } else {
                return false;
            }
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").BidList = BidList;

}, "", { requires: ["model-list", "bid-model", "collection"] });
