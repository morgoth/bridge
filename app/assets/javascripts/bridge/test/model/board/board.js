YUI.add("board-model-test", function (Y) {

    var isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;


    Y.namespace("Bridge.Test.Model").Board = new Y.Test.Case({

        name: "Board Tests",

        setUp: function () {
            this.board = new Y.Bridge.Model.Board();
        },

        // state

        testStateAuctionWithoutBids: function () {
            this.board.set("bids", []);

            areSame("auction", this.board.state());
        },

        testStateAuctionWithOneBid: function () {
            this.board.set("bids", [{ bid: "1C" }]);

            areSame("auction", this.board.state());
        },

        testStatePlayingWithContract: function () {
            this.board.set("bids", [{ bid: "1H" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);

            areSame("playing", this.board.state());
        },

        testStatePlayingWithContractAndOneCard: function () {
            this.board.set("bids", [{ bid: "1H" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);
            this.board.set("cards", [{ card: "HA" }]);

            areSame("playing", this.board.state());
        },

        testStateCompletedWithContractAndFiftyTwoCards: function () {
            this.board.set("bids", [{ bid: "1H" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);
            this.board.set("cards", [
                { card: "CA" }, { card: "DA" }, { card: "HA" }, { card: "SA" },
                { card: "CK" }, { card: "DK" }, { card: "HK" }, { card: "SK" },
                { card: "CQ" }, { card: "DQ" }, { card: "HQ" }, { card: "SQ" },
                { card: "CJ" }, { card: "DJ" }, { card: "HJ" }, { card: "SJ" },
                { card: "CT" }, { card: "DT" }, { card: "HT" }, { card: "ST" },
                { card: "C9" }, { card: "D9" }, { card: "H9" }, { card: "S9" },
                { card: "C8" }, { card: "D8" }, { card: "H8" }, { card: "S8" },
                { card: "C7" }, { card: "D7" }, { card: "H7" }, { card: "S7" },
                { card: "C6" }, { card: "D6" }, { card: "H6" }, { card: "S6" },
                { card: "C5" }, { card: "D5" }, { card: "H5" }, { card: "S5" },
                { card: "C4" }, { card: "D4" }, { card: "H4" }, { card: "S4" },
                { card: "C3" }, { card: "D3" }, { card: "H3" }, { card: "S3" },
                { card: "C2" }, { card: "D2" }, { card: "H2" }, { card: "S2" }
            ]);

            areSame("completed", this.board.state());
        },

        testStateCompletedWithFourPasses: function () {
            this.board.set("bids", [{ bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);

            areSame("completed", this.board.state());
        },

        // contract

        testContractReturnsUndefinedWhenNoContract: function () {
            this.board.set("bids", [{ bid: "PASS" }]);

            isUndefined(this.board.contract());
        },

        testContractReturnsLastContract: function () {
            this.board.set("bids", [{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "PASS" }, { bid: "1NT" }, { bid: "PASS" }]);

            areSame("1NT", this.board.contract());
        },

        testContractReturnsLastContractWithModifiers: function () {
            this.board.set("bids", [{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "PASS" }, { bid: "1NT" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "X" }, { bid: "XX" }, { bid: "PASS" }]);

            areSame("1NTXX", this.board.contract());
        },

        // trump

        testTrumpReturnsUndefinedWithoutContract: function () {
            isUndefined(this.board.trump());
        },

        testTrumpReturnsUndefinedWith1NTContract: function () {
            this.board.set("bids", [{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "PASS" }, { bid: "1NT" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "X" }, { bid: "XX" }, { bid: "PASS" }]);

            isUndefined(this.board.trump());
        },

        testTrumpReturnsHWith3HContract: function () {
            this.board.set("bids", [{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "PASS" }, { bid: "3H" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "X" }, { bid: "XX" }, { bid: "PASS" }]);

            areSame("H", this.board.trump());
        },

        // declarer

        testDeclarerReturnsUndefinedWhenNoBids: function () {
            isUndefined(this.board.declarer());
        },

        testDeclarerReturnsCorrectSideWithSuitDeclaredOnce: function () {
            this.board.setAttrs({ bids: [{ bid: "1C" }], dealer: "S" });

            areSame("S", this.board.declarer());
        },

        testDeclarerReturnsCorrectSideWithSuitDeclaredTwiceByDifferentSides: function () {
            this.board.setAttrs({ bids: [{ bid: "1C" }, { bid: "2C" }, { bid: "X" }], dealer: "S" });

            areSame("W", this.board.declarer());
        },

        testDeclarerReturnsCorrectSideWithSuitDeclaredTwiceBySameSides: function () {
            this.board.setAttrs({ bids: [{ bid: "1C" }, { bid: "2C" }, { bid: "X" }, { bid: "XX" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "3C" }], dealer: "E" });

            areSame("E", this.board.declarer());
        }

    });

}, "", { requires: ["test", "board-model"] });

