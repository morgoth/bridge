YUI.add("bid-model-list", function (Y) {

    var BidList = Y.Base.create("bid-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Bid,

        bids: function () {
            return Y.Array.map(this._items, function (bid) {
                return bid.get("bid");
            });
        },

        last: function (number) {
            number || (number = 1);

            return this._items.slice(-number);
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
