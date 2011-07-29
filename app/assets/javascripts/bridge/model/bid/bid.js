YUI.add("bid-model", function (Y) {

    var Bid = Y.Base.create("bid-model", Y.Model, [Y.Bridge.Model.Sync], {

        _url: function (options) {
            options.id || (options.id = this.get("id"));

            if (options.id) {
                return "/ajax/tables/" + options.tableId + "/bids/" + options.id + ".json";
            } else {
                return "/ajax/tables/" + options.tableId + "/bids.json";
            }
        }

    }, {

        ATTRS: {

            bid: {

            }

            // alert: {

            // },

            // message: {

            // }

        }

    });

    Y.namespace("Bridge.Model").Bid = Bid;

}, "", { requires: ["model", "sync"] });
