YUI.add("bid-model-list", function (Y) {

    var BidList = Y.Base.create("bid-model-list", Y.ModelList, [], {

        model: Y.Bridge.Model.Bid

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge.Model").BidList = BidList;

}, "", { requires: ["model-list", "bid-model"] });
