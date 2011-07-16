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
      this.after("passbox:bid", this._afterBid);
      this.after("newbidbox:bid", this._afterBid);
    },

    syncUI: function () {

    },

    _afterBid: function (event, bid) {
      this._fireBidEvent(bid);
    },

    _fireBidEvent: function (bid) {
      var alertData = this._getAlert();
      this._resetAlert();
      // TODO: Poprzedni format: (ja bym to wrzucił do obiektu tak jak niżej)
      // this.fire("bid", [bid, alert]);
      this.fire("bid", {}, {
        bid: bid,
        alert: alertData.alert,
        alertMsg: alertData.msg
      });
    },

    _getAlert: function () {
      return {
        alert: true,
        msg: "todo"
      };
    },

    _resetAlert: function () {

    },

    _renderBiddingBox: function () {
      var contentBox = this.get("contentBox");
      this.get("contentBox").append(Y.Node.create(
        '<div>Bid: (previous bid: ' + this.get("contract") + ') </div>'
      ));
    },

    _addChildren: function() {
      var ours = false,      // TODO: get that attr from somewhere
        contract = this.get("contract"),
        mods = Y.Bridge.parseModifiers(contract);
      this._passBox = new Y.Bridge.PassBox({
        enabledButtons: {
          pass: true,
          x: !ours && !mods,
          xx: ours && mods == "X"
        }
      });
      this.add(this._passBox);
      this._newBidBox = new Y.Bridge.NewBidBox({
        contract: contract
      });
      this.add(this._newBidBox);
    }

  }, {
    ATTRS: {

      contract: {
        setter: function (contract) {
          return (Y.Lang.isValue(contract) && Y.Bridge.isContract(contract)) ? contract : undefined;
        }
      }

    }
  });

  Y.namespace("Bridge").BiddingBox = BiddingBox;

}, "0", { requires: ["passbox", "newbidbox"] });
