YUI.add("card-model", function (Y) {

    var Card = Y.Base.create("card", Y.Model, [Y.Bridge.Model.Sync], {

        list: function () {
            return this.lists[0];
        },

        board: function () {
            return this.list() && this.list().board();
        },

        index: function () {
            return Y.Array.indexOf(this.list()._items, this);
        },

        trick: function () {
            return Math.floor((this.index() - 1) / 4);
        },

        direction: function () {
            // return Y.Bridge.DIRECTIONS[(this.board().declarerPosition() + this.index()) % 4];
        },

        suit: function () {
            return Y.Bridge.parseSuit(this.get("card"));
        },

        value: function () {
            return Y.Bridge.parseValue(this.get("card"));
        },

        _url: function (options) {
            options.id || (options.id = this.get("id"));

            if (options.id) {
                return "/ajax/tables/" + options.tableId + "/cards/" + options.id + ".json";
            } else {
                return "/ajax/tables/" + options.tableId + "/cards.json";
            }
        }

    }, {

        ATTRS: {

            card: {

            }

        }

    });

    Y.namespace("Bridge.Model").Card = Card;

}, "", { requires: ["model", "helpers", "sync"] });
