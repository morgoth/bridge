YUI.add("bid-model-test", function (Y) {

    var isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;


    Y.namespace("Bridge.Test.Model").Bid = new Y.Test.Case({

        name: "Bid Tests",

        setUp: function () {
            this.bid = new Y.Bridge.Model.Bid();
        },

        // index

        testBidIndexReturnsCorrectIndex: function () {
            var bidList = new Y.Bridge.Model.BidList();

            bidList.add([{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }]);

            areSame(0, bidList.item(0).index());
            areSame(1, bidList.item(1).index());
            areSame(2, bidList.item(2).index());
        },

        // direction

        testBidDirectionReturnsCorrectDirection: function () {
            var board = new Y.Bridge.Model.Board({ dealer: "E", bids: [{ bid: "PASS" }, { bid: "1C" }, { bid: "1D" }, { bid: "1H" }] });

            areSame("E", board.bids().item(0).direction());
            areSame("S", board.bids().item(1).direction());
            areSame("W", board.bids().item(2).direction());
            areSame("N", board.bids().item(3).direction());
        }

    });

}, "", { requires: ["test", "bid-model", "bid-model-list", "board-model"] });

