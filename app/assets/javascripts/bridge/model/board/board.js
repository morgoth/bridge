YUI.add("board-model", function (Y) {

    var Board = Y.Base.create("board", Y.Model, [], {

        initializer: function () {
            this._bidList = new Y.Bridge.Model.BidList();
            this._bidList._board = this;
            this._bidList.addTarget(this);

            this._cardList = new Y.Bridge.Model.CardList();
            this._cardList._board = this;
            this._cardList.addTarget(this);

            this.after("bidsChange", this._afterBidsChange);
            this.after("cardsChange", this._afterCardsChange);

            this._resetBids(this.get("bids"));
            this._resetCards(this.get("cards"));
        },

        bids: function () {
            return this._bidList;
        },

        cards: function () {
            return this._cardList;
        },

        dealerPosition: function () {
            return Y.Bridge.directionPosition(this.get("dealer"));
        },

        activeDirection: function () {
            switch (this.state()) {
            case "auction":
                return Y.Bridge.DIRECTIONS[(this.dealerPosition() + this.bids().size()) % 4];
                break;
            case "playing":
                return "N"; // TODO
                break;
            }
            return undefined;
        },

        _afterBidsChange: function (event) {
            this._resetBids(event.newVal);
        },

        _afterCardsChange: function (event) {
            this._resetCards(event.newVal);
        },

        _resetBids: function (bids) {
            this.bids().reset(bids);
        },

        _resetCards: function (cards) {
            this.cards().reset(cards);
        },

        contract: function () {
            var lastContract = this.bids().lastContract(),
                lastModifier = this.bids().lastModifier();

            if (lastContract && lastModifier && lastModifier.index() > lastContract.index()) {
                return lastContract.get("bid") + lastModifier.get("bid");
            } else {
                return lastContract && lastContract.get("bid");
            }
        },

        trump: function () {
            return Y.Bridge.parseSuit(this.contract());
        },

        trickNumber: function () {
            return Math.floor(this.cards().size() / 4);
        },

        trick: function () {
            return this.cards().trick(this.trickNumber());
        },

        leadSuit: function () {
            var lead = this.lead();

            return lead && lead.suit();
        },

        lead: function () {
            return this.trick()[0];
        },

        leadDirection: function () {

        },

        declarer: function () {
            var bid,
                lastContract = this.bids().lastContract();

            if (lastContract) {
                bid = this.bids().firstBidWithSuitAndSide(lastContract.suit(), lastContract.direction());

                return bid && bid.direction();
            } else {
                return undefined;
            }
        },

        declarerPosition: function () {
            return Y.Bridge.directionPosition(this.declarer());
        },

        state: function () {
            if (this.cards().isCompleted() || (this.bids().isCompleted() && !this.contract())) {
                return "completed";
            } else if (this.bids().isCompleted()) {
                return "playing";
            } else {
                return "auction";
            }
        },

        hand: function (direction) {
            var cards,
                result = this.get("deal")[direction] || ["", "", "", "", "", "", "", "", "", "", "", "", ""];

            if (result[0] !== "") {
                cards = this.cards().cards();

                return Y.Array.filter(result, function (card) {
                    return Y.Array.indexOf(cards, card) === -1;
                });
            } else {
                return result.slice(0, cardsLeft(direction)); // TODO: cardsLeft
            }
        }

    }, {

        ATTRS: {

            deal: {

            },

            dealer: {

            },

            vulnerable: {

            },

            // writeonly
            bids: {
                value: []
            },

            // writeonly
            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge.Model").Board = Board;

}, "", { requires: ["model", "bid-model-list", "card-model-list", "helpers", "collection"] });
