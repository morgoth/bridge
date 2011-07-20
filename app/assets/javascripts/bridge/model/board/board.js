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
