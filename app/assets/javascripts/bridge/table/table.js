YUI.add("table", function (Y) {

    var Table = Y.Base.create("table", Y.Widget, [], {

        renderUI: function () {
            this._renderGrid();
        },

        _renderGrid: function () {
            this._tlNode = this._renderGridNode("tl");
            this._tcNode = this._renderGridNode("tc");
            this._trNode = this._renderGridNode("tr");
            this._mlNode = this._renderGridNode("ml");
            this._mcNode = this._renderGridNode("mc");
            this._mrNode = this._renderGridNode("mr");
            this._blNode = this._renderGridNode("bl");
            this._bcNode = this._renderGridNode("bc");
            this._brNode = this._renderGridNode("br");
        },

        _renderGridNode: function (name) {
            return this.get("contentBox").appendChild('<div>').addClass(this.getClassName(name));
        },

        bindUI: function () {

        },

        syncUI: function () {

        }

    }, {

        ATTRS: {

        }

    });

    Y.namespace("Bridge").Table = Table;

}, "", { requires: ["widget", "hand", "auction", "biddingbox", "trick"] });
