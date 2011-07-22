YUI.add("biddingbox", function (Y) {

    var BiddingBox = Y.Base.create("biddingbox", Y.Widget, [], {

        renderUI: function () {
            this._renderAlertBox();
            this._renderPassBox();
            this._renderBidBox();
        },

        _renderAlertBox: function () {
            this._alertBox = new Y.Bridge.AlertBox().render(this.get("contentBox"));
        },

        _renderPassBox: function () {
            this._passBox = new Y.Bridge.PassBox().render(this.get("contentBox"));
        },

        _renderBidBox: function () {
            this._bidBox = new Y.Bridge.BidBox().render(this.get("contentBox"));
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
            var contract = this.get("contract"),
                mods = contract ? Y.Bridge.parseModifiers(contract) : "";

            this._passBox.set("enabledButtons", {
                PASS: true,
                X: !ours && !mods && Y.Lang.isValue(contract),
                XX: ours && mods === "X"
            });
        },

        _fireBidEvent: function (bid) {
            this.fire("bid", {}, {
                bid: bid,
                alert: this._alertBox.get("alert"),
                alertMessage: this._alertBox.get("alertMessage")
            });
            this._alertBox.reset("alert");
        }

    }, {

        ATTRS: {

            ours: {
                value: false,
                validator: Y.Lang.isBoolean
            },

            contract: {
                setter: function (contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            },

            visible: {
                value: false
            },

            disabled: {
                value: true
            }

        }
    });

    Y.namespace("Bridge").BiddingBox = BiddingBox;

}, "0", { requires: ["passbox", "bidbox", "alertbox"] });
