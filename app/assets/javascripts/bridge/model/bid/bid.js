YUI.add("bid-model", function (Y) {

    var Bid = Y.Base.create("bid", Y.Model, [Y.Bridge.Model.Sync], {

        list: function () {
            return this.lists[0];
        },

        board: function () {
            return this.list() && this.list().board();
        },

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
