YUI.add("board-model", function (Y) {

    var Board = Y.Base.create("board-model", Y.Model, [], {

        initializer: function () {
            this._bidList = new Y.Bridge.Model.BidList();
            this._bidList.parent = this;
            this._bidList.addTarget(this);

            this._cardList = new Y.Bridge.Model.CardList();
            this._cardList.parent = this;
            this._cardList.addTarget(this);

            this.after("bidsChange", this._afterBidsChange);
            this.after("cardsChange", this._afterCardsChange);

            this._resetBids(this.get("bids"));
            this._resetCards(this.get("cards"));
        },

        createBid: function (model, object, callback) {
            this._bidList.create(model, object, callback);
        },

        generateAuction: function () {
            return {
                bids: this._bidList.bids(),
                vulnerable: this.get("vulnerable"),
                dealer: this.get("dealer"),
                visible: true
            };
        },

        generateCards: function (direction) {
            var cards = this._cardList.cards(),
                result = this.get("deal")[direction];

            result = Y.Array.filter(result, function (card) {
                return Y.Array.indexOf(cards, card) === -1;
            });

            return result;
        },

        activeDirection: function () {
            var dealerPosition = Y.Bridge.directionPosition(this.get("dealer"));

            switch (this.get("state")) {
            case "auction":
                return Y.Bridge.DIRECTIONS[dealerPosition + this._bidList.size()];
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
            this._bidList.reset(bids);
        },

        _resetCards: function (cards) {
            this._cardList.reset(cards);
        },

        state: function () {
            if (this._cardList.isCompleted()) {
                return "completed";
            } else if (this._bidList.isCompleted()) {
                return "playing";
            } else {
                return "auction";
            }
        },

        hand: function (direction) {
            var cards,
                result = this.get("deal")[direction] || ["", "", "", "", "", "", "", "", "", "", "", "", ""];

            if (result[0] !== "") {
                cards = this._cardList.cards();

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

}, "", { requires: ["model", "bid-model-list", "card-model-list"] });
