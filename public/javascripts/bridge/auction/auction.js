YUI.add("auction", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Auction = Y.Base.create("auction", Y.Widget, [Y.WidgetParent], {

        renderUI: function() {
            this._renderAuction();
        },

        _renderAuction: function() {
            var tokens = Y.merge(Auction, { directions: ["N", "E", "S", "W"] });
            this.get("contentBox").setContent(Y.mustache(Auction.AUCTION_TEMPLATE, tokens));
        },

        bindUI: function() {
            this.after("bidsChange", this._afterBidsChange);
            this.after("dealerChange", this._afterDealerChange);
            this.after("vulnerableChange", this._afterVulnerableChange);
        },

        syncUI: function() {
            this._uiSyncBids(this.get("bids"));
        },

        _afterBidsChange: function(event) {
            this._uiSyncBids(event.newVal);
        },

        _afterDealerChange: function(event) {
            this._uiSyncDealer(event.newVal);
        },

        _afterVulnerableChange: function(event) {
            this._uiSyncVulnerable(event.newVal);
        },

        _uiSyncDealer: function(dealer) {
            this._uiSyncBids(this.get("bids"));
        },

        _uiClearBids: function() {
            while(this._items.length) {
                this._items[0].destroy();
            }
        },

        _uiSyncBids: function(bids) {
            bids = Y.clone(bids);

            this._uiClearBids();
            this._childrenContainer = this.get("contentBox").one(DOT + Auction.C_BIDS);

            // add empty bids
            for(var i = 0; i < Y.Array.indexOf(["N", "E", "S", "W"], this.get("dealer")); i++) {
                bids.unshift({});
            };

            Y.each(bids, function(bid, i) {
                this.add(new Y.Bridge.Bid(Y.merge(bid, { disabled: true, visible: true })));
            }, this);

            this._uiScrollDownBids();
        },

        _uiScrollDownBids: function() {
            var bidsNode = this.get("contentBox").one(DOT + Auction.C_BIDS);

            Y.later(0, this, function() {
                bidsNode.set("scrollTop", bidsNode.get("scrollHeight") - bidsNode.get("offsetHeight"));
            });
        },

        _uiSyncVulnerable: function(vulnerable) {
            var headerNodes = this.get("contentBox").all(DOT + Auction.C_HEADER);

            headerNodes.each(function(headerNode) {
                headerNode.removeClass(Auction.C_VULNERABLE);
            });

            switch(vulnerable) {
            case "NONE":
                // DO NOTHING
                break;
            case "NS":
                headerNodes.item(0).addClass(Auction.C_VULNERABLE);
                headerNodes.item(2).addClass(Auction.C_VULNERABLE);
                break;
            case "EW":
                headerNodes.item(1).addClass(Auction.C_VULNERABLE);
                headerNodes.item(3).addClass(Auction.C_VULNERABLE);
                break;
            case "BOTH":
                headerNodes.each(function(headerNode) {
                    headerNode.addClass(Auction.C_VULNERABLE);
                });
                break;
            }
        }

    }, {

        C_BIDS: getClassName("auction", "bids"),
        C_HEADERS: getClassName("auction", "headers"),
        C_HEADER: getClassName("auction", "header"),
        C_VULNERABLE: getClassName("auction", "vulnerable"),

        ATTRS: {

            dealer: {
                value: "N"
            },

            vulnerable: {
                value: "NONE"
            },

            bids: {
                value: []
            }

        },

        AUCTION_TEMPLATE: ''
            + '<ol class="{{C_HEADERS}}">'
            +   '{{#directions}}'
            +     '<li class="{{C_HEADER}}">{{.}}</li>'
            +   '{{/directions}}'
            + '</ol>'
            + '<ol class="{{C_BIDS}}"></ol>'

    });

    Y.Bridge.Auction = Auction;

}, "0", { requires: ["widget", "widget-parent", "bid"] });
