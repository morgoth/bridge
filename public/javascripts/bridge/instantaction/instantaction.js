YUI.add("instantaction", function(Y) {

    Y.namespace("Bridge");

    function InstantAction() {
        InstantAction.superclass.constructor.apply(this, arguments);
    }

    Y.extend(InstantAction, Y.Plugin.Base, {

        initializer: function() {
            this.afterHostEvent("biddingbox:bid", this._afterHostBiddingBoxBid);
            this.afterHostEvent("hand:card", this._afterHostHandCard);
            this.afterHostEvent("claim:claim", this._afterHostClaimClaim);
            this.afterHostEvent("claimpreview:accept", this._afterHostClaimPreviewAccept);
            this.afterHostEvent("claimpreview:reject", this._afterHostClaimPreviewReject);
        },

        _afterHostBiddingBoxBid: function(event) {
            var bids,
                host = this.get("host"),
                bid = event[0];

            bids = Y.clone(host.auction.get("bids"));
            bids.push({ bid: bid, alert: null });
            host.biddingBox.hide();
            host.auction.set("bids", bids);
        },

        _afterHostHandCard: function(event) {
            var cards, lead,
                host = this.get("host"),
                hand = event.target,
                card = event[0];

            lead = host.trick.get("lead");
            cards = Y.clone(host.trick.get("cards"));

            if(cards && cards.length < 4) {
                cards.push(card);
            } else {
                cards = [card];
                lead = hand.get("direction");
                Y.log(hand.get("direction"));
            }

            host.trick.set("lead", lead);
            host.trick.set("cards", cards);

            cards = Y.clone(hand.get("cards"));
            cards = Y.Array.reject(cards, function(c) {
                return c === card;
            });
            hand.set("cards", cards);
        },

        _afterHostClaimClaim: function(event) {
            var claim = event.target;

            claim.hide();
        },

        _afterHostClaimPreviewAccept: function(event) {
            var claimPreview = event.target;

            claimPreview.hide();
        },

        _afterHostClaimPreviewReject: function(event) {
            var claimPreview = event.target;

            claimPreview.hide();
        }

    }, {

        NAME: "instantaction",

        NS: "instantaction",

        ATTRS: {

        }

    });

    Y.Bridge.InstantAction = InstantAction;

}, "", { requires: ["plugin", "oop"] });
