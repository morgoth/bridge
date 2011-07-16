YUI.add("auctionbid", function (Y) {

    var AuctionBid = Y.Base.create("auctionbid", Y.Button, [], {



    }, {



    });

    Y.namespace("Bridge").AuctionBid = AuctionBid;

}, "0", { requires: ["gallery-button"] });
