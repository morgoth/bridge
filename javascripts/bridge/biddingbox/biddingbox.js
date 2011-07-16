YUI.add("biddingbox", function (Y) {

    var BiddingBox = Y.Base.create("biddingbox", Y.Widget, [Y.WidgetParent], {

        renderUI: function () {
            this._renderPassBox();
            this._renderNewBidBox();
        },

        _renderPassBox: function () {
            this.add(new Y.Bridge.PassBox);
        },

        _renderNewBidBox: function () {
            this.add(new Y.Bridge.NewBidBox());
        },

        bindUI: function () {
            this.after("passbox:bid", this._afterBid);
            this.after("newbidbox:bid", this._afterBid);
            this.after("contractChange", this._afterContractChange);
            this.after("oursChange", this._afterOursChange);
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
            this.item(1).set("contract", contract);
            this._syncOurs(this.get("ours")); // FIXME: it's not nice
        },

        _syncOurs: function (ours) {
            var modifiers = Y.Bridge.parseModifiers(this.get("contract"));

            this.item(0).setAttrs({ enabledButtons: { x: (!ours && !modifiers), xx: (ours && modifiers == "X") } });
        },

        _afterBid: function (event, bid) {
            this._fireBidEvent(bid);
        },

        _fireBidEvent: function (bid) {
            var alertData = this._getAlert();

            // this._resetAlert();
            // TODO: Poprzedni format: (ja bym to wrzucił do obiektu tak jak niżej)
            // this.fire("bid", [bid, alert]);
            this.fire("bid", {}, { bid: bid, alert: alertData.alert, alertMsg: alertData.msg });
        },

        _getAlert: function () {
            return {
                alert: true,
                msg: "todo"
            };
        },

        _setContract: function (contract) {
            return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
        }

    }, {

        ATTRS: {

            ours: {
                validator: Y.Lang.isBoolean
            },

            contract: {
                setter: "_setContract"
            }

        }
    });

    Y.namespace("Bridge").BiddingBox = BiddingBox;

}, "0", { requires: ["passbox", "newbidbox"] });
