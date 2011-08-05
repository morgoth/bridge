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
            return this.bids().contract();
        },

        state: function () {
            if (this.cards().isCompleted() || (this.bids().isCompleted() && !Y.Lang.isValue(this.contract()))) {
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
