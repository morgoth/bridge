YUI.add("table", function(Y) {

    Y.namespace("Bridge");

    function Table() {
        Table.superclass.constructor.apply(this, arguments);
    };

    Y.extend(Table, Y.Base, {

        initializer: function() {
            var id = this.get("id"),
                container = this.get("container");

            if(container && id) {
                this._renderTable();
                this._initializePoll();
                this.poll.start();
            }
        },

        _renderTable: function() {
            var container = this.get("container");

            container.set("innerHTML", "Bridge Libre!");
        },

        _initializePoll: function() {
            var tablePath,
                timeout = this.get("pollTimeout"),
                id = this.get("id");

            tablePath = Y.substitute(Table.TABLE_PATH, { ID: id });

            this.poll = Y.io.poll(timeout, tablePath, {
                on: {
                    modified: this._pollModified
                }
            });
        },

        _pollModified: function(id, o) {
            var tableData = Y.JSON.parse(o.responseText);
        }

    }, {

        NAME: "table",

        ATTRS: {

            id: {
                readOnly: true,
                getter: function() {
                    var container = this.get("container");

                    return parseInt(container && container.getAttribute("data-table-id"));
                }
            },

            container: {
                value: "body",
                setter: function(selector) {
                    return Y.one(selector);
                }
            },

            pollTimeout: {
                value: 3000,
                validator: Y.Lang.isNumber
            }

        },

        TABLE_PATH: "/ajax/tables/{ID}.json"

    });

    Y.Bridge.Table = Table;

}, "0", { requires: ["base", "node", "gallery-io-poller", "json", "substitute"] });
