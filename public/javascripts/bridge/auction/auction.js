YUI.add("auction", function(Y) {

    Y.namespace("Bridge");

    function Auction() {
        Auction.superclass.constructor.apply(this, arguments);
    };

    Y.extend(Auction, Y.Widget, {
        renderUI: function() {
            this._renderAuction();
        },

        bindUI: function() {
            this.after("bidsChange", this._afterBidsChange);
            this.after("dealerChange", this._afterDealerChange);
        },

        syncUI: function() {
            this._uiSetBids(this.get("bids"));
        },

        _afterBidsChange: function(event) {
            this._uiSetBids(event.newVal);
        },

        _afterDealerChange: function(event) {
            this._uiSetDealer(event.newVal);
        },

        _uiSetDealer: function(dealer) {
            this._uiSetBids(this.get("bids"));
        },

        _renderAuction: function() {
            var html, headers,
                dealer = this.get("dealer"),
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

        _uiSetBids: function(bids) {
            var bidsNode, html, dealerPosition,
                dealer = this.get("dealer"),
                contentBox = this.get("contentBox");
            bidsNode = contentBox.one("." + this.getClassName("bids"));
            dealerPosition = Y.Array.indexOf(Auction.DIRECTIONS, dealer);
            bids = Y.Array.map(bids, function(bid, i) {
                var player = Auction.DIRECTIONS[(i + dealerPosition) % 4];

                return {
                    name: bid,
                    className: this.getClassName("bid", bid.toLowerCase()),
                    player: player
                };
            }, this);

            for(var i = 0; i < dealerPosition; i++) {
                bids.unshift({});
            }

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

        AUCTION_TEMPLATE: ''
            + '<ol>'
            +   '{{#headers}}'
            +     '<li class="yui-auction-header {{className}}">{{name}}</li>'
            +   '{{/headers}}'
            +   '</ol>'
            +   '<ol class="yui-auction-bids"></ol>'
            + '</ol>',

        BIDS_TEMPLATE: ''
            + '{{#bids}}'
            +   '<li>'
            +     '{{#name}}'
            +       '<button type="button" class="yui-auction-bid {{className}}" data-player="{{player}}">'
            +         '{{name}}'
            +       '</button>'
            +     '{{/name}}'
            +   '</li>'
            + '{{/bids}}'

    });

    Y.Bridge.Auction = Auction;

}, "0", { requires: ["widget"] });
