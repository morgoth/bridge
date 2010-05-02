YUI.add("info", function(Y) {

    Y.namespace("Bridge");

    function Info() {
        Info.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Info, Y.Widget, {

        renderUI: function() {
            this._renderInfo();
        },

        _renderInfo: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Info.INFO_TEMPLATE, {
                firstRowCN: this.getClassName("row", "1"),
                secondRowCN: this.getClassName("row", "2"),
                thirdRowCN: this.getClassName("row", "3"),
                firstColCN: this.getClassName("col", "1"),
                secondColCN: this.getClassName("col", "2"),
                thirdColCN: this.getClassName("col", "3"),
                firstDirectionCN: this.getClassName("direction", "1"),
                secondDirectionCN: this.getClassName("direction", "2"),
                thirdDirectionCN: this.getClassName("direction", "3"),
                fourthDirectionCN: this.getClassName("direction", "4"),
                infoCN: this.getClassName("info")
            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            this.after("playerChange", this._afterPlayerChange);
            this.after("dealerChange", this._afterDealerChange);
            this.after("vulnerableChange", this._afterVulnerableChange);
            this.after("tableIdChange", this._afterTableIdChange);
        },

        _afterPlayerChange: function(event) {
            this._uiSetDealer(this.get("dealer"));
            this._uiSetVulnerable(this.get("vulnerable"));
        },

        _afterDealerChange: function(event) {
            this._uiSetDealer(event.newVal);
        },

        _afterVulnerableChange: function(event) {
            this._uiSetVulnerable(event.newVal);
        },

        _afterTableIdChange: function(event) {
            this._uiSetTableId(event.newVal);
        },

        syncUI: function() {
            this._uiSetDealer(this.get("dealer"));
            this._uiSetVulnerable(this.get("vulnerable"));
            this._uiSetTableId(this.get("tableId"));
        },

        _uiSetDealer: function(dealer) {
            var directionNodes, distance,
                player = this.get("player"),
                contentBox = this.get("contentBox");
            directionNodes = [
                contentBox.one("." + this.getClassName("direction", "1")),
                contentBox.one("." + this.getClassName("direction", "2")),
                contentBox.one("." + this.getClassName("direction", "3")),
                contentBox.one("." + this.getClassName("direction", "4"))
            ];
            distance = Y.Bridge.directionDistance(player, dealer);

            Y.each(directionNodes, function(directionNode) {
                directionNode.set("innerHTML", "");
            }, this);

            directionNodes[(distance + 2) % 4].set("innerHTML", "D");
        },

        _uiSetVulnerable: function(vulnerable) {
            var directionNodes,
                vulnerableCN = this.getClassName("vulnerable"),
                player = this.get("player"),
                contentBox = this.get("contentBox");
            directionNodes = [
                contentBox.one("." + this.getClassName("direction", "1")),
                contentBox.one("." + this.getClassName("direction", "2")),
                contentBox.one("." + this.getClassName("direction", "3")),
                contentBox.one("." + this.getClassName("direction", "4"))
            ];

            Y.each(directionNodes, function(directionNode) {
                directionNode.removeClass(vulnerableCN);
            }, this);

            // OPTIMIZE
            switch(vulnerable) {
            case "NONE":
                // do nothing
                break;
            case "NS":
                if("NS".indexOf(player) !== -1) {
                    directionNodes[0].addClass(vulnerableCN);
                    directionNodes[2].addClass(vulnerableCN);
                } else {
                    directionNodes[1].addClass(vulnerableCN);
                    directionNodes[3].addClass(vulnerableCN);
                }
                break;
            case "EW":
                if("EW".indexOf(player) !== -1) {
                    directionNodes[0].addClass(vulnerableCN);
                    directionNodes[2].addClass(vulnerableCN);
                } else {
                    directionNodes[1].addClass(vulnerableCN);
                    directionNodes[3].addClass(vulnerableCN);
                }
                break;
            case "BOTH":
                Y.each(directionNodes, function(directionNode) {
                    directionNode.addClass(vulnerableCN);
                }, this);
                break;
            }
        },

        _uiSetTableId: function(tableId) {
            var infoNode,
                contentBox = this.get("contentBox");
            infoNode = contentBox.one("." + this.getClassName("info"));

            infoNode.set("innerHTML", "Table " + tableId);
        }

    }, {

        NAME: "info",

        ATTRS: {

            player: {
                setter: function(player) {
                    return Y.Bridge.isDirection(player) ? player : "S";
                },
                value: "S"
            },

            dealer: {
                validator: Y.Bridge.isDirection
            },

            vulnerable: {
                validator: Y.Bridge.isVulnerability
            },

            tableId: {
                validator: Y.Lang.isNumber
            }

        },

        INFO_TEMPLATE: ''
            + '<table>'
            +   '<tbody>'
            +     '<tr class="{{firstRowCN}}">'
            +       '<td></td>'
            +       '<td class="{{secondColCN}}">'
            +         '<div class="{{firstDirectionCN}}"></div>'
            +       '</td>'
            +       '<td></td>'
            +     '</tr>'
            +     '<tr class="{{secondRowCN}}">'
            +       '<td class="{{firstColCN}}">'
            +         '<div class="{{fourthDirectionCN}}"></div>'
            +       '</td>'
            +       '<td class="{{secondColCN}}">'
            +         '<div class="{{infoCN}}"></div>'
            +       '</td>'
            +       '<td class="{{thirdColCN}}">'
            +         '<div class="{{secondDirectionCN}}"></div>'
            +       '</td>'
            +     '</tr>'
            +     '<tr class="{{thirdRowCN}}">'
            +       '<td></td>'
            +       '<td class="{{secondColCN}}">'
            +         '<div class="{{thirdDirectionCN}}"></div>'
            +       '</td>'
            +       '<td></td>'
            +     '</tr>'
            +   '</tbody>'
            + '</table>'

    });

    Y.Bridge.Info = Info;

}, "0", { requires: ["widget", "mustache", "helpers"] });
