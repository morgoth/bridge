YUI.add("auctionbid", function (Y) {

    var AuctionBid = Y.Base.create("auctionbid", Y.Button, [], {

        syncUI: function () {
            this.constructor.superclass.syncUI.apply(this, arguments);
            this._syncBid(this.get("bid"));
        },

        _syncBid: function (bid) {
            if (Y.Lang.isValue(bid)) {
                this.set("label", bid);
            } else {
                this.set("label", "");
            }
        },

        _setBid: function (bid) {
            return Y.Bridge.isContract(bid) ? bid : undefined;
        }

    }, {

        ATTRS: {

            bid: {
                setter: "_setBid"
            }

        }

    });

    Y.namespace("Bridge").AuctionBid = AuctionBid;

}, "0", { requires: ["gallery-button", "helpers"] });
