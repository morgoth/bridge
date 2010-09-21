YUI.add("bid", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Bid = Y.Base.create("bid", Y.Widget, [Y.WidgetChild], {

        BOUNDING_TEMPLATE : "<li></li>",
        CONTENT_TEMPLATE : "<dl></dl>",

        initializer: function() {
            this.publish("bid");
        },

        syncUI: function() {
            this._uiSyncBid(this.get("bid"));
        },

        _renderedSuit: function(bid) {
            var suit = this._getSuit(bid);

            switch(suit) {
            case "C":
                return "&clubs;";
                break;
            case "D":
                return "&diams;";
                break;
            case "H":
                return "&hearts;";
                break;
            case "S":
                return "&spades;";
                break;
            case "NT":
                return "NT";
            default:
                return "";
                break;
            }
        },

        _renderedValue: function(bid) {
            var value = this._getValue(bid);

            switch(value) {
            case "PASS":
                return "Pass";
                break;
            case "X":
                return "Dbl";
                break;
            case "XX":
                return "Rdbl";
                break;
            default:
                return value;
                break;
            }
        },

        _uiSyncBid: function(bid) {
            if(bid) {
                var tokens = Y.merge(Bid, {
                    renderedValue: this._renderedValue(bid),
                    value: this._getValue(bid).toLowerCase(),
                    renderedSuit: this._renderedSuit(bid),
                    suit: this._getSuit(bid) && this._getSuit(bid).toLowerCase()
                });

                this.get("contentBox").setContent(Y.mustache(Bid.BID_TEMPLATE, tokens));
            } else {
                this.get("contentBox").setContent("");
            }
        },

        _uiSyncAlert: function(alert) {
            if(alert) {
                this.get("contentBox").addClass(Bid.C_ALERT).setAttribute("title", alert);
            } else {
                this.get("contentBox").removeClass(Bid.C_ALERT).removeAttribute("title");
            }
        },

        bindUI: function() {
            this.after("bidChange", this._afterBidChange);
            this.get("contentBox").on("click", this._onContentBoxClick, this);
        },

        _afterBidChange: function(event) {
            this._uiSyncBid(event.newVal);
        },

        _onContentBoxClick: function(event) {
            if(!this.get("disabled")) {
                this.fire("bid", [this.get("bid")]);
            }
        },

        _setBid: function(bid) {
            return Y.Lang.isString(bid) && /^((1|2|3|4|5|6|7)(C|D|H|S|NT)|PASS|X|XX)$/.test(bid) ? bid : undefined;
        },

        _getSuit: function(bid) {
            var matchData;
            bid = bid || this.get("bid");

            matchData = bid && bid.match(/^(1|2|3|4|5|6|7)(C|D|H|S|NT)$/);
            return matchData ? matchData[2] : undefined;
        },

        _getValue: function(bid) {
            var matchData;
            bid = bid || this.get("bid");

            matchData = bid && bid.match(/1|2|3|4|5|6|7|X|XX|PASS/);
            return matchData ? matchData[0] : undefined;
        },

        _setAlert: function(alert) {
            return Y.Lang.isString(alert) && alert !== "" ? alert : undefined;
        }

    }, {

        C_ALERT: getClassName("bid", "alert"),
        C_VALUE: getClassName("bid", "value"),
        C_SUIT:  getClassName("bid", "suit"),

        ATTRS: {

            alert: {
                value: undefined,
                setter: "_setAlert"
            },

            bid: {
                value: undefined,
                setter: "_setBid"
            },

            suit: {
                getter: "_getSuit",
                readOnly: true
            },

            value: {
                getter: "_getValue",
                readOnly: true
            }

        },

        BID_TEMPLATE: ''
            + '{{#value}}<dt class="{{C_VALUE}}">{{renderedValue}}</dt>{{/value}}'
            + '{{#suit}}<dd class="{{C_SUIT}} {{C_SUIT}}-{{suit}}">{{renderedSuit}}</dd>{{/suit}}'

    });

    Y.Bridge.Bid = Bid;

}, "0", { requires: ["widget", "widget-child", "mustache"] });
