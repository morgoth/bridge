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

        last: function (number) {
            number || (number = 1);

            return this._items.slice(-number);
        },

        contracts: function () {
            return Y.Array.reduce(this._items, [], function (result, bid) {
                if (Y.Bridge.isContract(bid.get("bid"))) {
                    result.push(bid.get("bid"));
                }
                return result;
            });
        },

        modifier: function () {
            return Y.Array.reduce(this._items, undefined, function (result, bid) {
                if (Y.Bridge.isContract(bid.get("bid"))) {
                    return undefined;
                } else if (Y.Bridge.isModifier(bid.get("bid"))) {
                    return bid.get("bid");
                } else {
                    return result;
                }
            });
        },

        contract: function () {
            var contract,
                modifier = this.modifier(),
                contracts = this.contracts();

            contract = contracts[contracts.length - 1];

            if (Y.Lang.isValue(contract) && Y.Lang.isValue(modifier)) {
                return contract + modifier;
            } else {
                return contract;
            }
        },

        isCompleted: function () {
            if (this.size() > 3) {
                return Y.Array.every(this.last(3), function (bid) {
                    return bid.get("bid") === "PASS";
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
