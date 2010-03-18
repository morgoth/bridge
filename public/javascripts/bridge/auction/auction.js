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

        _renderAuction: function() {
            var html, headers,
                contentBox = this.get("contentBox");
            headers = Y.Array.map(Auction.DIRECTIONS, function(direction) {
                return {
                    name: direction,
                    className: this.getClassName("header", direction.toLowerCase())
                };
            }, this);
            html = Y.mustache(Auction.AUCTION_TEMPLATE, {
                headers: headers
            });

            contentBox.set("innerHTML", html);
        },

        // TODO:
        _uiSetBids: function(bids) {
            var bidsNode, html,
                contentBox = this.get("contentBox");
            bidsNode = contentBox.one("." + this.getClassName("bids"));
            bids = Y.Array.map(bids, function(bid, i) {
                return {
                    name: bid,
                    className: this.getClassName("bid", bid.toLowerCase())
                };
            }, this);
            html = Y.mustache(Auction.BIDS_TEMPLATE, {
                bids: bids
            });

            bidsNode.set("innerHTML", html);
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

        AUCTION_TEMPLATE: '' +
            '<ol>' +
              '{{#headers}}' +
                '<li class="yui-auction-header {{className}}">{{name}}</li>' +
              '{{/headers}}' +
            '</ol>' +
            '<ol class="yui-auction-bids">' +
            '</ol>',

        BIDS_TEMPLATE: '' +
            '{{#bids}}' +
              '<li>' +
                '<button type="button" class="yui-auction-bid {{className}}">{{name}}</button>' +
              '</li>' +
            '{{/bids}}'

    });

    Y.Bridge.Auction = Auction;

}, "0", { requires: ["widget"] });
