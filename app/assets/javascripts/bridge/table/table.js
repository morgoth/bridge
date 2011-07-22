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
            this._topHand = new Y.Bridge.Hand().render(this._tcNode);
            this._rightHand = new Y.Bridge.Hand().render(this._mrNode);
            this._bottomHand = new Y.Bridge.Hand().render(this._bcNode);
            this._leftHand = new Y.Bridge.Hand().render(this._mlNode);
        },

        _renderTrick: function () {
            this._trick = new Y.Bridge.Trick().render(this._mcNode);
        },

        _renderBiddingBox: function () {
            this._biddingBox = new Y.Bridge.BiddingBox().render(this._brNode);
        },

        _renderAuction: function () {
            this._auction = new Y.Bridge.Auction().render(this._trNode);
        },

        bindUI: function () {
            this.after("topHandChange", this._afterTopHandChange);
            this.after("leftHandChange", this._afterLeftHandChange);
            this.after("bottomHandChange", this._afterBottomHandChange);
            this.after("rightHandChange", this._afterRightHandChange);
            this.after("trickChange", this._afterTrickChange);
            this.after("biddingBoxChange", this._afterBiddingBoxChange);
            this.after("auctionChange", this._afterAuctionChange);
        },

        _afterTopHandChange: function (event) {
            this._syncTopHand(event.newVal);
        },

        _afterLeftHandChange: function (event) {
            this._syncLeftHand(event.newVal);
        },

        _afterBottomHandChange: function (event) {
            this._syncBottomHand(event.newVal);
        },

        _afterRightHandChange: function (event) {
            this._syncRightHand(event.newVal);
        },

        _afterTrickChange: function (event) {
            this._syncTrick(event.newVal);
        },

        _afterBiddingBoxChange: function (event) {
            this._syncBiddingBox(event.newVal);
        },

        _afterAuctionChange: function (event) {
            this._syncAuction(event.newVal);
        },

        syncUI: function () {

        },

        _syncTopHand: function (topHand) {
            this._topHand.setAttrs(topHand);
        },

        _syncLeftHand: function (leftHand) {
            this._leftHand.setAttrs(leftHand);
        },

        _syncBottomHand: function (bottomHand) {
            this._bottomHand.setAttrs(bottomHand);
        },

        _syncRightHand: function (rightHand) {
            this._rightHand.setAttrs(rightHand);
        },

        _syncTrick: function (trick) {
            this._trick.setAttrs(trick);
        },

        _syncBiddingBox: function (biddingBox) {
            this._biddingBox.setAttrs(biddingBox);
        },

        _syncAuction: function (auction) {
            this._auction.setAttrs(auction);
        }

    }, {

        ATTRS: {

            state: {
                value: ""
            },

            topHand: {
                value: {}
            },

            leftHand: {
                value: {}
            },

            bottomHand: {
                value: {}
            },

            rightHand: {
                value: {}
            },

            trick: {
                value: {}
            },

            biddingBox: {
                value: {}
            },

            auction: {
                value: {}
            }

        }

    });

    Y.namespace("Bridge").Table = Table;

}, "", { requires: ["widget", "hand", "auction", "biddingbox", "trick"] });
