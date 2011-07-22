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

        generateAuction: function () {
            return {
                bids: this._bidList.getBids(),
                vulnerable: this.get("vulnerable"),
                dealer: this.get("dealer"),
                visible: true
            };
        },

        generateCards: function (direction) {
            var cards = this._cardList.getCards(),
                result = this.get("deal")[direction];

            result = Y.Array.filter(result, function (card) {
                return Y.Array.indexOf(cards, card) === -1;
            });

            return result;
        },

        state: function () {
            var bidsCount = this._bidList.size(),
                cardsCount = this._cardList.size();


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
        }

    }, {

        ATTRS: {

            deal: {
                value: {
                    "N": ["", "", "", "", "", "", "", "", "", "", "", "", ""],
                    "E": ["", "", "", "", "", "", "", "", "", "", "", "", ""],
                    "S": ["", "", "", "", "", "", "", "", "", "", "", "", ""],
                    "W": ["", "", "", "", "", "", "", "", "", "", "", "", ""]
                }
            },

            dealer: {

            },

            vulnerable: {

            },

            declarer: {
                value: null
            },

            contract: {
                value: null
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
