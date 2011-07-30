YUI.add("sync", function (Y) {

    var Sync = function () {

    };

    Sync.prototype = {
        sync: function (action, options, callback) {
            options || (options = {});

            var configuration = {
                on: {
                    success: function (transactionId, response) {
                        callback(null, response.responseText);
                    },
                    failure: function (transactionId, response) {
                        callback(response.statusText, response.responseText);
                    }
                }
            };

            switch (action) {
            case "create":
                configuration.data = {};
                configuration.data[this.get("name")] = this.toJSON();
                configuration.method = "POST";
                break;
            case "update":
                configuration.data = { _method: "PUT" };
                configuration.data[this.get("name")] = this.toJSON();
                configuration.method = "POST";
                break;
            case "read":
                configuration.method = "GET";
                break;
            case "delete":
                configuration.data = { _method: "DELETE" };
                configuration.method = "POST";
                break;
            }

            Y.io(this._url(options), configuration);
        }
    };

    Y.namespace("Bridge.Model").Sync = Sync;

}, "", { requires: ["io", "querystring-stringify"] });
