YUI().use("hand", "trick", "biddingbox", "auction", function (Y) {
    this.Y = Y;

    var cards = ["SA", "SK", "SQ", "SJ", "ST", "S9", "S8", "S7", "S6", "S5", "S4", "S3", "S2",
                 "HA", "HK", "HQ", "HJ", "HT", "H9", "H8", "H7", "H6", "H5", "H4", "H3", "H2",
                 "DA", "DK", "DQ", "DJ", "DT", "D9", "D8", "D7", "D6", "D5", "D4", "D3", "D2",
                 "CA", "CK", "CQ", "CJ", "CT", "C9", "C8", "C7", "C6", "C5", "C4", "C3", "C2"],
      contract = "2D";

    window.biddingBox = new Y.Bridge.BiddingBox({ contract: contract }).render();

    // Test
    window.biddingBox.after("bid", function (event, data) {
        var msg = "Your bid is: " + data.bid + "\n";
        if (data.alert) {
            msg += "alert: " + data.alertMsg;
        } else {
            msg += "no alert";
        }
        alert(msg);
    });

    window.hand = new Y.Bridge.Hand({ cards: cards }).render();

    window.trick = new Y.Bridge.Trick({ cards: ["CA", "DA", "HA", "SA"] }).render();

    window.auction = new Y.Bridge.Auction({}).render();
});
