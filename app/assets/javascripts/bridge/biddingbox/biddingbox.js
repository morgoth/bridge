YUI.add("biddingbox", function (Y) {

    var BiddingBox = Y.Base.create("biddingbox", Y.Widget, [], {

        renderUI: function () {
            this._renderPassBox();
            this._renderBidBox();
            this._renderAlertBox();
        },

        _renderPassBox: function () {
            this._passBox = new Y.Bridge.PassBox().render(this.get("contentBox"));
        },

        _renderBidBox: function () {
            this._bidBox = new Y.Bridge.BidBox().render(this.get("contentBox"));
        },

        _renderAlertBox: function () {
            this._alertBox = new Y.Bridge.AlertBox().render(this.get("contentBox"));
        },

        bindUI: function () {
            this._passBox.after("bid", this._afterBid, this);
            this._bidBox.after("bid", this._afterBid, this);
            this.after("contractChange", this._afterContractChange);
            this.after("oursChange", this._afterOursChange);
        },

        _afterBid: function (event, bid) {
            this._fireBidEvent(bid);
        },

        _afterContractChange: function (event) {
            this._syncContract(event.newVal);
        },

        _afterOursChange: function (event) {
            this._syncOurs(event.newVal);
        },

        syncUI: function () {
            this._syncContract(this.get("contract"));
            this._syncOurs(this.get("ours"));
        },

        _syncContract: function (contract) {
            this._bidBox.set("contract", contract);
            this._syncOurs(this.get("ours")); // FIXME: it's not nice
        },

        _syncOurs: function (ours) {
            var mods = Y.Bridge.parseModifiers(this.get("contract"));

            this._passBox.set("enabledButtons", { PASS: true, X: !ours && !mods, XX: ours && mods == "X" });
        },

        _fireBidEvent: function (bid) {
            var alertData = this._getAlert();

            this.fire("bid", {}, {
                bid: bid,
                alert: alertData.alert,
                alertMsg: alertData.alertMsg
            });
        },

        _getAlert: function () {
            return this._alertBox.getAlertAndResetUI();
        }

    }, {

        ATTRS: {

            ours: {
                validator: Y.Lang.isBoolean
            },

            contract: {
                setter: function (contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            }

        }
    });

    Y.namespace("Bridge").BiddingBox = BiddingBox;

}, "0", { requires: ["passbox", "bidbox", "alertbox"] });
