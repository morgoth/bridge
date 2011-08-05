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
        }

    });

}, "", { requires: ["test", "board-model"] });

