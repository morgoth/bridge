YUI.add("auction", function (Y) {

    var Auction = Y.Base.create("auction", Y.Widget, [Y.WidgetParent], {

        renderUI: function () {
            this._renderHeaders();
            this._renderChildrenContainer();
        },

        _renderHeaders: function () {
            this._headersNode = this.get("contentBox").appendChild('<ol>').addClass(this.getClassName("headers"));
            this._headerNodes = [];
            Y.each(["N", "E", "S", "W"], function (direction) {
                this._headerNodes.push(this._headersNode.appendChild('<li>').setContent(direction));
            }, this);
        },

        _renderChildrenContainer: function () {
            this._childrenContainer = this.get("contentBox").appendChild('<ol>').addClass(this.getClassName("bids"));
        },

        bindUI: function () {
            this.after("bidsChange", this._afterBidsChange);
            this.after("dealerChange", this._afterDealerChange);
            this.after("vulnerableChange", this._afterVulnerableChange);
        },

        syncUI: function () {
            this._uiSyncBids(this.get("bids"));
        },

        _afterBidsChange: function (event) {
            this._uiSyncBids(event.newVal);
        },

        _afterDealerChange: function (event) {
            this._uiSyncDealer(event.newVal);
        },

        _afterVulnerableChange: function (event) {
            this._uiSyncVulnerable(event.newVal);
        },

        _uiSyncDealer: function (dealer) {
            this._uiSyncBids(this.get("bids"));
        },

        _uiSyncBids: function (bids) {
            // bids = Y.clone(bids);

            // this._childrenContainer = this.get("contentBox").one(DOT + Auction.C_BIDS);

            // // add empty bids
            // for (var i = 0; i < Y.Array.indexOf(["N", "E", "S", "W"], this.get("dealer")); i++) {
            //     bids.unshift({});
            // };

            // Y.each(bids, function (bid, i) {
            //     this.add(new Y.Bridge.Bid(Y.merge(bid, { disabled: true, visible: true })));
            // }, this);

            // this._uiScrollDownBids();
        },

        _uiScrollDownBids: function () {
            Y.later(0, this, function () {
                this._childrenContainer.set("scrollTop", this._childrenContainer.get("scrollHeight") - this._childrenContainer.get("offsetHeight"));
            });
        },

        _uiSyncVulnerable: function (vulnerable) {
            var nodeArray = {
                    "NONE": [],
                    "NS":   [0, 2],
                    "EW":   [1, 3],
                    "BOTH": [0, 1, 2, 3]
                }[vulnerable];

            Y.each(this._headerNodes, function (node, i) {
                if (Y.Array.indexOf(nodeArray, i) !== -1) {
                    node.addClass(this.getClassName("vulnerable"));
                } else {
                    node.removeClass(this.getClassName("vulnerable"));
                }
            }, this);
        }

    }, {

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

        }

    });

    Y.namespace("Bridge").Auction = Auction;

}, "0", { requires: ["widget", "widget-parent", "auctionbid"] });
