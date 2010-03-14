YUI.add("auction", function(Y) {

    Y.namespace("Bridge");

    function Auction() {
        Auction.superclass.constructor.apply(this, arguments);
    };

    Y.extend(Auction, Y.Widget, {
        renderUI: function() {
            this._renderHeader();
            this._renderBids();
        },

        bindUI: function() {
            this.after("bidsChange", this._afterBidsChange);
            this.after("dealerChange", this._afterDealerChange);
            this.bidsNode.delegate("click", Y.bind(this._onBidClick, this), "[position]");
        },

        syncUI: function() {
            this._uiSetBids(this.get("bids"));
        },

        addBid: function(bid) {
            var bids = this.get("bids");

            bids.push(bid);
            this.set("bids", bids);
        },

        _onBidClick: function(event) {
            var position = event.target.getAttribute("position");

            this.fire("bid", [position]);
        },

        _afterBidsChange: function(event) {
            this._uiSetBids(event.newVal);
        },

        _afterDealerChange: function(event) {
            this._uiSetDealer(event.newVal);
        },

        _uiSetDealer: function(dealer) {
            this.bidsNode.all(":empty").remove();

            Y.each(Auction.DIRECTIONS.slice(0, Y.Array.indexOf(Auction.DIRECTIONS, dealer)), function(direction) {
                var bidNode = this._createBid("", this.getClassName("bid", "space"));

                this.bidsNode.prepend(bidNode);
            }, this);
        },

        _uiSetBids: function(bids) {
            var dealer = this.get("dealer"),
                indexOfDealer = Y.Array.indexOf(Auction.DIRECTIONS, dealer);

            this.bidsNode.all("*").remove();
            this._uiSetDealer(dealer);

            Y.each(bids, function(bid, i) {
                var className = this.getClassName("bid", Auction.DIRECTIONS[(i + indexOfDealer) % 4].toLowerCase()),
                    bidNode = this._createBid(bid, className);

                bidNode.setAttribute("position", i + 1);
                this.bidsNode.appendChild(bidNode);
            }, this);
        },

        _renderHeader: function() {
            var contentBox = this.get("contentBox");

            this.headerNode = this._createBidGroup(this.getClassName("headers"));
            contentBox.appendChild(this.headerNode);

            this.headerNodes = {};
            Y.each(Auction.DIRECTIONS, function(direction) {
                var headerNode = this._createBid(direction, this.getClassName("header", direction.toLowerCase()));

                this.headerNodes[direction] = headerNode;
                this.headerNode.appendChild(headerNode);
            }, this);
        },

        _renderBids: function() {
            var contentBox = this.get("contentBox");

            this.bidsNode = this._createBidGroup(this.getClassName("bids"));
            contentBox.appendChild(this.bidsNode);
        },

        _createBidGroup: function(className) {
            var bidGroup = Y.Node.create(Auction.BID_GROUP_TEMPLATE);

            bidGroup.addClass(className);

            return bidGroup;
        },

        _createBid: function(text, className) {
            var bid = Y.Node.create(Auction.BID_TEMPLATE);

            bid.set("innerHTML", text);
            bid.addClass(className);

            return bid;
        }
    }, {

        NAME: "auction",

        ATTRS: {

            dealer: {
                value: "N"
            },

            bids: {
                value: []
            }

        },

        DIRECTIONS: ["N", "E", "S", "W"],

        BID_GROUP_TEMPLATE: '<ol></ol>',

        BID_TEMPLATE: '<li></li>'


    });

    Y.Bridge.Auction = Auction;

}, "0", { requires: ["widget"] });
