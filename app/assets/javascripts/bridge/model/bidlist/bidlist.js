YUI.add("bid-model-list", function (Y) {

    var BidList = Y.Base.create("bid-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Bid,

        getBids: function () {
            return Y.Array.map(this._items, function (bid) {
                return bid.getAttrs(["bid", "alert", "message"]);
            });
        },

        isFinished: function () {
            if (this.size() > 3) {

            } else if (this.size() === 4) {

            }
        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").BidList = BidList;

}, "", { requires: ["model-list", "bid-model"] });
