YUI.add("auction", function(Y) {

    var each = Y.each,
        bind = Y.bind,
        indexOf = Y.Array.indexOf,
        Widget = Y.Widget,
        Node = Y.Node,
        AUCTION = "auction",
        HEADER = "header",
        BID = "bid",
        DIRECTIONS = ["N", "E", "S", "W"],
        BID_GROUP_TEMPLATE = '<ol></ol>',
        BID_TEMPLATE = '<li></li>';


    function Auction() {
        Auction.superclass.constructor.apply(this, arguments);
    }

    Y.mix(Auction, {
        NAME: AUCTION,
        ATTRS: {
            dealer: {
                value: "N"
            },
            bids: {
                value: []
            },
            names: {
                value: DIRECTIONS
            }
        }
    });

    Y.extend(Auction, Widget, {
        renderUI: function() {
            this._renderHeader();
            this._renderBids();
        },

        bindUI: function() {
            this.after("bidsChange", this._afterBidsChange);
            this.after("dealerChange", this._afterDealerChange);
            this.bidsNode.delegate("click", bind(this._onBidClick, this), "[position]");
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

            each(DIRECTIONS.slice(0, indexOf(DIRECTIONS, dealer)), function(direction) {
                var bidNode = this._createBid("", this.getClassName("bid", "space"));

                this.bidsNode.prepend(bidNode);
            }, this);
        },

        _uiSetBids: function(bids) {
            var dealer = this.get("dealer"),
                indexOfDealer = indexOf(DIRECTIONS, dealer);

            this.bidsNode.all("*").remove();
            this._uiSetDealer(dealer);

            each(bids, function(bid, i) {
                var className = this.getClassName("bid", DIRECTIONS[(i + indexOfDealer) % 4].toLowerCase()),
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
            each(DIRECTIONS, function(direction) {
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
            var bidGroup = Node.create(BID_GROUP_TEMPLATE);

            bidGroup.addClass(className);

            return bidGroup;
        },

        _createBid: function(text, className) {
            var bid = Node.create(BID_TEMPLATE);

            bid.set("innerHTML", text);
            bid.addClass(className);

            return bid;
        }
    });

    Y.Auction = Auction;

}, "0", {
    requires: ["widget"]
});

