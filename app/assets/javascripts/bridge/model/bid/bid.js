YUI.add("bid-model", function (Y) {

    var Bid = Y.Base.create("bid-model", Y.Model, [], {



    }, {

        ATTRS: {

            bid: {

            }

        }

    });

    Y.namespace("Bridge.Model").Bid = Bid;

}, "", { requires: ["model"] });
