YUI().use("hand", "trick", "tricks", "biddingbox", "auction", "table-model", function (Y) {
    this.Y = Y;

    var cards = ["SA", "SK", "SQ", "SJ", "ST", "S9", "S8", "S7", "S6", "S5", "S4", "S3", "S2",
                 "HA", "HK", "HQ", "HJ", "HT", "H9", "H8", "H7", "H6", "H5", "H4", "H3", "H2",
                 "DA", "DK", "DQ", "DJ", "DT", "D9", "D8", "D7", "D6", "D5", "D4", "D3", "D2",
                 "CA", "CK", "CQ", "CJ", "CT", "C9", "C8", "C7", "C6", "C5", "C4", "C3", "C2"];

    window.tricks = new Y.Bridge.Tricks({ player: "N" }).render();

    window.biddingBox = new Y.Bridge.BiddingBox({ contract: "2D", ours: false }).render();
    window.hand = new Y.Bridge.Hand({ cards: cards, name: "qoobaa", direction: "N" }).render();

    window.trick = new Y.Bridge.Trick({ cards: ["CA", "DA", "HA", "SA"] }).render();

    window.auction = new Y.Bridge.Auction({ bids: ["1C", "1D", "1HX", "1S", "1NT", "2NT", "PASS", "PASS", "PASS"], dealer: "E" }).render();


    // UI Tests

    // -Tricks-
    // Add sample tricks
    var tricks = [];

    for (var i = 0; i < 13; i++) {
        var f = function(i){
            var winner = "NESW"[i % 4];
            tricks.push({ get: function () { return winner; }});
        }(i);
    }
    // window.tricks.set("tricks", tricks.slice(0,5));
    window.tricks.set("tricks", tricks);
    // Rotate player
    window.tricks.set("player", "W");

    // -BiddingBox-
    // Show choosen bid
    window.biddingBox.after("bid", function (event, data) {
        var msg = "Your bid is: " + data.bid + "\n";

        if (data.alert) {
            msg += "alert: " + data.alertMessage;
        } else {
            msg += "no alert";
        }
        alert(msg);
    });

});
