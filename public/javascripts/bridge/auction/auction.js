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
            this.after("vulnerableChange", this._afterVulnerableChange);
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

        _afterVulnerableChange: function(event) {
            this._uiSetVulnerable(event.newVal);
        },

        _uiSetDealer: function(dealer) {
            this._uiSetBids(this.get("bids"));
        },

        _renderAuction: function() {
            var html, headers,
                dealer = this.get("dealer"),
                contentBox = this.get("contentBox");
            headers = Y.Array.map(Y.Bridge.DIRECTIONS, function(direction) {
                return {
                    name: direction,
                    classNames: this.getClassName("header", direction.toLowerCase())
                };
            }, this);
            html = Y.mustache(Auction.AUCTION_TEMPLATE, {
                headers: headers,
                headersCN: this.getClassName("headers")
            });

            contentBox.set("innerHTML", html);
        },

        _uiSetBids: function(bids) {
            var bidsNode, html, dealerPosition,
                dealer = this.get("dealer"),
                contentBox = this.get("contentBox");
            bidsNode = contentBox.one("." + this.getClassName("bids"));
            dealerPosition = Y.Array.indexOf(Y.Bridge.DIRECTIONS, dealer);

            bids = Y.Array.map(bids, function(bid, i) {
                var player = Y.Bridge.DIRECTIONS[(i + dealerPosition) % 4],
                    classNames = [this.getClassName("bid", bid.bid.toLowerCase())];

                if (bid.alert) {
                    classNames[classNames.length] = this.getClassName("bid", "alerted");
                }

                return {
                    name: Y.Bridge.renderBid(bid.bid),
                    classNames: classNames.join(" "),
                    alert: bid.alert,
                    player: player
                };
            }, this);

            for(var i = 0; i < dealerPosition; i++) {
                // add empty bids
                bids.unshift({});
            }

            html = Y.mustache(Auction.BIDS_TEMPLATE, {
                bids: bids
            });

            bidsNode.set("innerHTML", html);
            Y.later(0, this, function() {
                var scrollHeight = bidsNode.get("scrollHeight"),
                    offsetHeight = bidsNode.get("offsetHeight");

                bidsNode.set("scrollTop", scrollHeight - offsetHeight);
            });
        },

        _uiSetVulnerable: function(vulnerable) {
            var headerNodeN, headerNodeE, headerNodeS, headerNodeW,
                contentBox = this.get("contentBox"),
                vulnerableCN = this.getClassName("header", "vulnerable");

            headerNodeN = contentBox.one("." + this.getClassName("header", "n")).removeClass(vulnerableCN);
            headerNodeE = contentBox.one("." + this.getClassName("header", "e")).removeClass(vulnerableCN);
            headerNodeS = contentBox.one("." + this.getClassName("header", "s")).removeClass(vulnerableCN);
            headerNodeW = contentBox.one("." + this.getClassName("header", "w")).removeClass(vulnerableCN);

            switch(vulnerable) {
            case "NONE":
                // DO NOTHING
                break;
            case "NS":
                headerNodeN.addClass(vulnerableCN);
                headerNodeS.addClass(vulnerableCN);
                break;
            case "EW":
                headerNodeE.addClass(vulnerableCN);
                headerNodeW.addClass(vulnerableCN);
                break;
            case "BOTH":
                headerNodeN.addClass(vulnerableCN);
                headerNodeE.addClass(vulnerableCN);
                headerNodeS.addClass(vulnerableCN);
                headerNodeW.addClass(vulnerableCN);
                break;
            }
        }

    }, {

        NAME: "auction",

        ATTRS: {

            dealer: {
                value: "N"
            },

            vulnerable: {
                value: "NONE"
            },

            bids: {
                value: []
            },

            strings: {
                value: {
                    modifiers: {
                        PASS: "Pass",
                        X: "Dbl",
                        XX: "Rdbl"
                    },
                    suits: {
                        C: "&clubs;",
                        D: "&diams;",
                        H: "&hearts;",
                        S: "&spades;",
                        NT: "NT"
                    }
                }
            }
        },

        AUCTION_TEMPLATE: ''
            + '<ol class="{{headersCN}}">'
            +   '{{#headers}}'
            +     '<li class="yui3-auction-header {{classNames}}">{{name}}</li>'
            +   '{{/headers}}'
            + '</ol>'
            + '<ol class="yui3-auction-bids"></ol>'
            + '</ol>'
            + '<div class="yui3-auction-clear"></div>',

        BIDS_TEMPLATE: ''
            + '{{#bids}}'
            +   '<li>'
            +     '{{#name}}'
            +       '<button type="button" class="yui3-auction-bid {{classNames}}" data-player="{{player}}" title="{{alert}}">'
            +         '{{{name}}}'
            +       '</button>'
            +     '{{/name}}'
            +   '</li>'
            + '{{/bids}}'

    });

    Y.Bridge.Auction = Auction;

}, "0", { requires: ["widget"] });
