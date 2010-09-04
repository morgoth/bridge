YUI.add("info", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

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

            html = Y.mustache(Info.INFO_TEMPLATE, Info);

            contentBox.setContent(html);
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
            var directionSelectors, distance,
                player = this.get("player");

            directionSelectors = [
                DOT + Info.C_FIRST_DIRECTION,
                DOT + Info.C_SECOND_DIRECTION,
                DOT + Info.C_THIRD_DIRECTION,
                DOT + Info.C_FOURTH_DIRECTION
            ];

            Y.each(directionSelectors, function(directionSelector) {
                this._uiSetContent(directionSelector, "");
            }, this);

            if(dealer) {
                distance = Y.Bridge.directionDistance(player, dealer);
                this._uiSetContent(directionSelectors[(distance + 2) % 4], "D");
            }
        },

        _uiSetVulnerable: function(vulnerable) {
            var directionNodes,
                player = this.get("player"),
                contentBox = this.get("contentBox");

            directionNodes = [
                contentBox.one(DOT + Info.C_FIRST_DIRECTION),
                contentBox.one(DOT + Info.C_SECOND_DIRECTION),
                contentBox.one(DOT + Info.C_THIRD_DIRECTION),
                contentBox.one(DOT + Info.C_FOURTH_DIRECTION)
            ];

            Y.each(directionNodes, function(directionNode) {
                directionNode.removeClass(Info.C_VULNERABLE);
            }, this);

            // OPTIMIZE
            switch(vulnerable) {
            case "NONE":
                // do nothing
                break;
            case "NS":
                if("NS".indexOf(player) !== -1) {
                    directionNodes[0].addClass(Info.C_VULNERABLE);
                    directionNodes[2].addClass(Info.C_VULNERABLE);
                } else {
                    directionNodes[1].addClass(Info.C_VULNERABLE);
                    directionNodes[3].addClass(Info.C_VULNERABLE);
                }
                break;
            case "EW":
                if("EW".indexOf(player) !== -1) {
                    directionNodes[0].addClass(Info.C_VULNERABLE);
                    directionNodes[2].addClass(Info.C_VULNERABLE);
                } else {
                    directionNodes[1].addClass(Info.C_VULNERABLE);
                    directionNodes[3].addClass(Info.C_VULNERABLE);
                }
                break;
            case "BOTH":
                Y.each(directionNodes, function(directionNode) {
                    directionNode.addClass(Info.C_VULNERABLE);
                }, this);
                break;
            }
        },

        _uiSetTableId: function(tableId) {
            this._uiSetContent(DOT + Info.C_INFO, "Table " + tableId);
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
                setter: function(dealer) {
                    return Y.Bridge.isDirection(dealer) ? dealer : undefined;
                }
            },

            vulnerable: {
                setter: function(vulnerable) {
                    return Y.Bridge.isVulnerability(vulnerable) ? vulnerable : "NONE";
                },
                value: "NONE"
            },

            tableId: {
                validator: Y.Lang.isNumber
            }

        },

        C_FIRST_ROW:        getClassName("info", "row", "1"),
        C_SECOND_ROW:       getClassName("info", "row", "2"),
        C_THIRD_ROW:        getClassName("info", "row", "3"),
        C_FIRST_COL:        getClassName("info", "col", "1"),
        C_SECOND_COL:       getClassName("info", "col", "2"),
        C_THIRD_COL:        getClassName("info", "col", "3"),
        C_FIRST_DIRECTION:  getClassName("info", "direction", "1"),
        C_SECOND_DIRECTION: getClassName("info", "direction", "2"),
        C_THIRD_DIRECTION:  getClassName("info", "direction", "3"),
        C_FOURTH_DIRECTION: getClassName("info", "direction", "4"),
        C_INFO:             getClassName("info", "info"),
        C_VULNERABLE:       getClassName("info", "vulnerable"),

        INFO_TEMPLATE: ''
            + '<table>'
            +   '<tbody>'
            +     '<tr class="{{C_FIRST_ROW}}">'
            +       '<td></td>'
            +       '<td class="{{C_SECOND_COL}}">'
            +         '<div class="{{C_FIRST_DIRECTION}}"></div>'
            +       '</td>'
            +       '<td></td>'
            +     '</tr>'
            +     '<tr class="{{C_SECOND_ROW}}">'
            +       '<td class="{{C_FIRST_COL}}">'
            +         '<div class="{{C_FOURTH_DIRECTION}}"></div>'
            +       '</td>'
            +       '<td class="{{C_SECOND_COL}}">'
            +         '<div class="{{C_INFO}}"></div>'
            +       '</td>'
            +       '<td class="{{C_THIRD_COL}}">'
            +         '<div class="{{C_SECOND_DIRECTION}}"></div>'
            +       '</td>'
            +     '</tr>'
            +     '<tr class="{{C_THIRD_ROW}}">'
            +       '<td></td>'
            +       '<td class="{{C_SECOND_COL}}">'
            +         '<div class="{{C_THIRD_DIRECTION}}"></div>'
            +       '</td>'
            +       '<td></td>'
            +     '</tr>'
            +   '</tbody>'
            + '</table>'

    });

    Y.augment(Info, Y.Bridge.UiHelper);

    Y.Bridge.Info = Info;

}, "0", { requires: ["widget", "mustache", "helpers", "uihelper"] });
