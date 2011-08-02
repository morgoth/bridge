YUI.add("bid-model-list-test", function (Y) {

    var isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;


    Y.namespace("Bridge.Test.Model").BidList = new Y.Test.Case({

        name: "Bid List Tests",

        setUp: function () {
            this.bidList = new Y.Bridge.Model.BidList();
        },

        // last

        testLastReturnsLastBid: function () {
            var bid1C = new Y.Bridge.Model.Bid({ bid: "1C" }),
                bid1D = new Y.Bridge.Model.Bid({ bid: "1D" });

            this.bidList.add([bid1C, bid1D]);

            areSame(1, this.bidList.last().length);
            areSame(bid1D, this.bidList.last()[0]);
        },

        testLastReturnsThreeLastBids: function () {
            var bid1C = new Y.Bridge.Model.Bid({ bid: "1C" }),
                bid1D = new Y.Bridge.Model.Bid({ bid: "1D" }),
                bid1H = new Y.Bridge.Model.Bid({ bid: "1H" }),
                bid1S = new Y.Bridge.Model.Bid({ bid: "1S" });

            this.bidList.add([bid1C, bid1D, bid1H, bid1S]);

            areSame(3, this.bidList.last(3).length);
            areSame(bid1D, this.bidList.last(3)[0]);
            areSame(bid1H, this.bidList.last(3)[1]);
            areSame(bid1S, this.bidList.last(3)[2]);
        },

        // isCompleted

        testIsNotCompletedWhenEmpty: function () {
            isFalse(this.bidList.isCompleted());
        },

        testIsNotCompletedWithOnePass: function () {
            this.bidList.add({ bid: "PASS" });

            isFalse(this.bidList.isCompleted());
        },

        testIsNotCompletedWithThreePasses: function () {
            this.bidList.add([{ bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);

            isFalse(this.bidList.isCompleted());
        },

        testCompletedWithContractAndThreePasses: function () {
            this.bidList.add([{ bid: "1C" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);

            isTrue(this.bidList.isCompleted());
        },

        testCompletedWithFourPasses: function () {
            this.bidList.add([{ bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "PASS" }]);

            isTrue(this.bidList.isCompleted());
        },

        // contracts

        testContractsReturnsContractsOnly: function () {
            this.bidList.add([{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "1D" }]);

            areSame(2, this.bidList.contracts().length);
            areSame("1C", this.bidList.contracts()[0]);
            areSame("1D", this.bidList.contracts()[1]);
        },

        // modifier

        testModifierReturnsLastModifier: function () {
            this.bidList.add([{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "XX" }, { bid: "PASS" }, { bid: "1D" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "X" }]);

            areSame("X", this.bidList.modifier());
        },

        // contract

        testContractReturnsUndefinedWhenNoContract: function () {
            this.bidList.add([{ bid: "PASS" }]);

            isUndefined(this.bidList.contract());
        },

        testContractReturnsLastContract: function () {
            this.bidList.add([{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "PASS" }, { bid: "1NT" }, { bid: "PASS" }]);

            areSame("1NT", this.bidList.contract());
        },

        testContractReturnsLastContractWithModifiers: function () {
            this.bidList.add([{ bid: "PASS" }, { bid: "1C" }, { bid: "X" }, { bid: "PASS" }, { bid: "1NT" }, { bid: "PASS" }, { bid: "PASS" }, { bid: "X" }, { bid: "XX" }, { bid: "PASS" }]);

            areSame("1NTXX", this.bidList.contract());
        }

    });

}, "", { requires: ["test", "bid-model-list"] });

