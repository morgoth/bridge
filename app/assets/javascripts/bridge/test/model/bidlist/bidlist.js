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
        }

    });

}, "", { requires: ["test", "bid-model-list"] });

