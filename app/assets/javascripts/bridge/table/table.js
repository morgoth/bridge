YUI.add("table", function (Y) {

    var Table = Y.Base.create("table", Y.Widget, [], {

        renderUI: function () {
            this._renderPlaceholders();
            this._renderHands();
            this._renderTrick();
            this._renderBiddingBox();
            this._renderAuction();
        },

        _renderPlaceholders: function () {
            this._tlNode = this._renderPlaceholder("tl");
            this._tcNode = this._renderPlaceholder("tc");
            this._trNode = this._renderPlaceholder("tr");
            this._mlNode = this._renderPlaceholder("ml");
            this._mcNode = this._renderPlaceholder("mc");
            this._mrNode = this._renderPlaceholder("mr");
            this._blNode = this._renderPlaceholder("bl");
            this._bcNode = this._renderPlaceholder("bc");
            this._brNode = this._renderPlaceholder("br");
        },

        _renderPlaceholder: function (name) {
            return this.get("contentBox").appendChild('<div>').addClass(this.getClassName("placeholder", name)).addClass(this.getClassName("placeholder"));
        },

        _renderHands: function () {
            this._topHand = new Y.Bridge.Hand({ direction: "N", cards: ["", "", "", "", "", "", "", "", "", "", "", "", ""] }).render(this._tcNode);
            this._rightHand = new Y.Bridge.Hand({ direction: "E", cards: ["", "", "", "", "", "", "", "", "", "", "", "", ""] }).render(this._mrNode);
            this._bottomHand = new Y.Bridge.Hand({ direction: "S", cards: ["", "", "", "", "", "", "", "", "", "", "", "", ""] }).render(this._bcNode);
            this._leftHand = new Y.Bridge.Hand({ direction: "W", cards: ["", "", "", "", "", "", "", "", "", "", "", "", ""] }).render(this._mlNode);
        },

        _renderTrick: function () {
            this._trick = new Y.Bridge.Trick({ cards: ["CA", "DA", "HA", "SA"], dealer: "N" }).render(this._mcNode);
        },

        _renderBiddingBox: function () {
            this._biddingBox = new Y.Bridge.BiddingBox({ contract: "1C" }).render(this._brNode);
        },

        _renderAuction: function () {
            this._auction = new Y.Bridge.Auction({ bids: ["PASS", "PASS", "1H", "PASS", "PASS", "PASS"], dealer: "E" }).render(this._trNode);
        },

        bindUI: function () {

        },

        syncUI: function () {

        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge").Table = Table;

}, "", { requires: ["widget", "hand", "auction", "biddingbox", "trick"] });
