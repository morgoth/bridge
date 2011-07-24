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

            this._refreshBids(this.get("bids"));
            this._refreshCards(this.get("cards"));
        },

        _afterBidsChange: function (event) {
            this._refreshBids(event.newVal);
        },

        _afterCardsChange: function (event) {
            this._refreshCards(event.newVal);
        },

        _refreshBids: function (bids) {
            this._bidList.refresh(bids);
        },

        _refreshCards: function (cards) {
            this._cardList.refresh(cards);
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

            bids: {
                value: []
            },

            cards: {
                value: []
            }

        }

    });

    Y.namespace("Bridge.Model").Board = Board;

}, "", { requires: ["model", "bid-model-list", "card-model-list"] });
