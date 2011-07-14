YUI.add("biddingbox", function (Y) {

    var BiddingBox = Y.Base.create("biddingbox", Y.Widget, [Y.WidgetParent], {
        initializer: function () {
            this._addChildren();
        },

        renderUI: function () {
            this._renderBiddingBox();
        },

        bindUI: function () {
            var contentBox = this.get("contentBox");
        },

        syncUI: function () {

        },

        _fireBidEvent: function (bid) {
            var alert = this._getAlert();
            this._resetAlert();
            this.fire("bid", [bid, alert]);
        },

        _getAlert: function () {

        },

        _resetAlert: function () {

        },

        _renderBiddingBox: function () {
            contentBox = this.get("contentBox");
            this.get('contentBox').append(Y.Node.create(
                '<div>Bid:</div>'
            ));
        },

        _addChildren: function() {
            this._passBox = new Y.Bridge.PassBox();
            this.add(this._passBox);
        },

    }, {

        NAME: "biddingbox",

        ATTRS: {

            contract: {
                setter: function (contract) {
                    return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
                }
            }

        },
    });

    Y.namespace("Bridge").BiddingBox = BiddingBox;

}, "0", { requires: ["passbox"] });
