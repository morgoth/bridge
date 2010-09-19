YUI.add("instantaction", function(Y) {

    Y.namespace("Bridge");

    function InstantAction() {
        InstantAction.superclass.constructor.apply(this, arguments);
    }

    Y.extend(InstantAction, Y.Plugin.Base, {

        initializer: function() {
            this.afterHostEvent("tableDataChange", this._afterHostTableDataChange);
            this.afterHostEvent("biddingbox:bid", this._afterHostBiddingBoxBid);
            this.afterHostEvent("card:card", this._afterHostCardCard);
            this.afterHostEvent("claim:claim", this._afterHostClaimClaim);
            this.afterHostEvent("claimpreview:accept", this._afterHostClaimPreviewAccept);
            this.afterHostEvent("claimpreview:reject", this._afterHostClaimPreviewReject);
        },

        _afterHostTableDataChange: function(event) {
            this.set("enabled", true);
        },

        _afterHostBiddingBoxBid: function(event) {
            var bids,
                enabled = this.get("enabled"),
                host = this.get("host"),
                bid = event[0];

            if(enabled) {
                bids = host.auction.get("bids");
                bids.push({ bid: bid, alert: null });
                host.biddingBox.hide();
                host.auction.set("bids", bids);
                host.auction.show();
                this.set("enabled", false);
            }
        },

        _afterHostCardCard: function(event) {
            var cards, lead,
                enabled = this.get("enabled"),
                host = this.get("host"),
                hand = event.target.get("parent"),
                card = event[0];

            if(enabled) {
                lead = host.trick.get("lead");
                cards = host.trick.get("cards");

                if(cards && cards.length < 4) {
                    cards.push(card);
                } else {
                    cards = [card];
                    lead = hand.get("direction");
                }

                host.trick.set("lead", lead);
                host.trick.set("cards", cards);
                host.trick.show();

                cards = hand.get("cards");
                cards = Y.Array.reject(cards, function(c) {
                    return c === card;
                });
                hand.set("cards", cards);
                this.set("enabled", false);
            }
        },

        _afterHostClaimClaim: function(event) {
            var claim = event.target,
                enabled = this.get("enabled");

            if(enabled) {
                claim.hide();
                this.set("enabled", false);
            }
        },

        _afterHostClaimPreviewAccept: function(event) {
            var claimPreview = event.target,
                enabled = this.get("enabled");

            if(enabled) {
                claimPreview.hide();
                this.set("enabled", false);
            }
        },

        _afterHostClaimPreviewReject: function(event) {
            var claimPreview = event.target,
                enabled = this.get("enabled");

            if(enabled) {
                claimPreview.hide();
                this.set("enabled", false);
            }
        }

    }, {

        NAME: "instantaction",

        NS: "instantaction",

        ATTRS: {

            enabled: {
                value: true
            }

        }

    });

    Y.Bridge.InstantAction = InstantAction;

}, "", { requires: ["plugin"] });
