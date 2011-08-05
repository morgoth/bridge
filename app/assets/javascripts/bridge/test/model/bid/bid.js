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

        // suit

        testBidSuitReturnsUndefinedWithPass: function () {
            this.bid.set("bid", "PASS");

            isUndefined(this.bid.suit());
        },

        testBidSuitReturnsUndefinedWithXX: function () {
            this.bid.set("bid", "XX");

            isUndefined(this.bid.suit());
        },

        testBidSuitReturnsNTWith1NT: function () {
            this.bid.set("bid", "1NT");

            areSame("NT", this.bid.suit());
        },

        testBidSuitReturnsHWith1H: function () {
            this.bid.set("bid", "1H");

            areSame("H", this.bid.suit());
        },

        // level

        testLevelReturnsUndefinedWithPass: function () {
            this.bid.set("bid", "PASS");

            isUndefined(this.bid.level());
        },

        testLevelReturns5With5H: function () {
            this.bid.set("bid", "5H");

            areSame(5, this.bid.level());
        },

        // isPass

        testIsPassReturnsTrueWithPass: function () {
            this.bid.set("bid", "PASS");

            isTrue(this.bid.isPass());
        },

        testIsPassReturnsFalseWithDouble: function () {
            this.bid.set("bid", "X");

            isFalse(this.bid.isPass());
        },

        // isDouble

        testIsDoubleReturnsTrueWithDouble: function () {
            this.bid.set("bid", "X");

            isTrue(this.bid.isDouble());
        },

        testIsDoubleReturnsFalseWithRedouble: function () {
            this.bid.set("bid", "XX");

            isFalse(this.bid.isDouble());
        },

        // isRedouble

        testIsRedoubleReturnsTrueWithRedouble: function () {
            this.bid.set("bid", "XX");

            isTrue(this.bid.isRedouble());
        },

        testIsRedoubleReturnsFalseWithDouble: function () {
            this.bid.set("bid", "X");

            isFalse(this.bid.isRedouble());
        },

        // isModifier

        testIsModifierReturnsTrueWithRedouble: function () {
            this.bid.set("bid", "XX");

            isTrue(this.bid.isModifier());
        },

        testIsModifierReturnsFalseWithPass: function () {
            this.bid.set("bid", "PASS");

            isFalse(this.bid.isModifier());
        },

        // isContract

        testIsContractReturnsTrueWith5NT: function () {
            this.bid.set("bid", "5NT");

            isTrue(this.bid.isContract());
        },

        testIsContractReturnsFalseWithPass: function () {
            this.bid.set("bid", "PASS");

            isFalse(this.bid.isContract());
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

