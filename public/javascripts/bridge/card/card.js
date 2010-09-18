YUI.add("card", function(Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    Y.namespace("Bridge");

    var Card = Y.Base.create("card", Y.Widget, [Y.WidgetChild], {

        BOUNDING_TEMPLATE : "<li></li>",
        CONTENT_TEMPLATE : "<em></em>",

        initializer: function() {
            this.publish("card");
        },

        syncUI: function() {
            this._uiSyncCard(this.get("card"));
        },

        _renderedValue: function(card) {
            var value = this._getValue(card);

            if(value === "T") {
                return "10";
            } else {
                return value;
            }
        },

        _renderedSuit: function(card) {
            var suit = this._getSuit(card);

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
            default:
                return "";
                break;
            }
        },

        _suitsArray: function(card) {
            var value = this._getValue(card);

            switch(value) {
            case "A":
                return [9];
                break;
            case "2":
                return [2, 15];
                break;
            case "3":
                return [2, 9, 15];
                break;
            case "4":
                return [1, 3, 14, 16];
                break;
            case "5":
                return [1, 3, 9, 14, 16];
                break;
            case "6":
                return [1, 3, 8, 10, 14, 16];
                break;
            case "7":
                return [1, 3, 5, 8, 10, 14, 16];
                break;
            case "8":
                return [1, 3, 6, 7, 11, 12, 14, 16];
                break;
            case "9":
                return [1, 3, 6, 7, 9, 11, 12, 14, 16];
                break;
            case "T":
                return [1, 3, 4, 6, 7, 11, 12, 13, 14, 16];
                break;
            case "J":
                return [1, 16];
                break;
            case "Q":
                return [1, 16];
                break;
            case "K":
                return [1, 16];
                break;
            default:
                return [];
                break;
            }
        },

        _hasImage: function(card) {
            var value = this._getValue(card);

            return value === "J" || value === "Q" || value === "K";
        },

        _uiSyncCard: function(card) {
            var suits,
                contentBox = this.get("contentBox"),
                tokens = Y.merge(Card);

            if(card === "") {
                contentBox.setContent(Y.mustache(Card.CARD_UNKNOWN_TEMPLATE, tokens));
            } else {
                tokens.card = card.toLowerCase();
                tokens.value = this._getValue(card).toLowerCase();
                tokens.suit = this._getSuit(card).toLowerCase();
                tokens.suitContent = this._renderedSuit(card);
                tokens.valueContent = this._renderedValue(card);
                tokens.image = this._hasImage(card);
                tokens.imagesBase = this.get("imagesBase");
                tokens.imageWidth = this.get("imageWidth");
                tokens.imageHeight = this.get("imageHeight");

                Y.each(this._suitsArray(card), function(suit) {
                    tokens[suit] = true;
                });

                contentBox.setContent(Y.mustache(Card.CARD_TEMPLATE, tokens));
            }

        },

        bindUI: function() {
            var contentBox = this.get("contentBox");

            this.after("cardChange", this._afterCardChange);
            contentBox.on("click", this._onContentBoxClick, this);
        },

        _afterCardChange: function(event) {
            this._uiSyncCard(event.newVal);
        },

        _onContentBoxClick: function(event) {
            if(!this.get("disabled")) {
                this.fire("card", [this.get("card"), this.get("position")]);
            }
        },

        _getSuit: function(card) {
            var matchData;

            card = card || this.get("card");
            matchData = card && card.match(/C|D|H|S/);
            return matchData ? matchData[0] : undefined;
        },

        _getValue: function(card) {
            var matchData;

            card = this.get("card");
            matchData = card && card.match(/2|3|4|5|6|7|8|9|T|J|Q|K|A/);
            return matchData ? matchData[0] : undefined;
        },

        _setCard: function(card) {
            return Y.Lang.isString(card) && /^(C|D|H|S)(2|3|4|5|6|7|8|9|T|J|Q|K|A)$/.test(card) ? card : "";
        }

    }, {

        ATTRS: {
            card: {
                value: "",
                setter: "_setCard"
            },

            suit: {
                getter: "_getSuit",
                readOnly: true
            },

            value: {
                getter: "_getValue",
                readOnly: true
            },

            position: {
            },

            imagesBase: {
                value: "/bridge/card/assets/skins/sam/"
            },

            imageHeight: {
                value: 90
            },

            imageWidth: {
                value: 53
            }

        },

        C_CARD_CARD:         getClassName("card", "card"),
        C_CARD_SUIT:         getClassName("card", "suit"),
        C_CARD_SUITS:        getClassName("card", "suits"),
        C_CARD_IMAGE:        getClassName("card", "image"),
        C_CARD_COVER:        getClassName("card", "cover"),
        C_CARD_UNKNOWN:      getClassName("card", "unknown"),
        C_CARD_VALUE:        getClassName("card", "value"),
        C_CARD_VALUE_TOP:    getClassName("card", "value", "top"),
        C_CARD_VALUE_BOTTOM: getClassName("card", "value", "bottom"),
        C_CARD_VALUE_VALUE:  getClassName("card", "value", "value"),
        C_CARD_UPSIDE_DOWN:  getClassName("card", "upside", "down"),

        CARD_TEMPLATE: ''
            + '<div class="{{C_CARD_CARD}} {{C_CARD_VALUE}}-{{value}} {{C_CARD_SUIT}}-{{suit}} {{C_CARD_CARD}}-{{card}}"">'
            +   '<div class="{{C_CARD_VALUE}} {{C_CARD_VALUE_TOP}}">'
            +     '<div class="{{C_CARD_VALUE_VALUE}}">{{{valueContent}}}</div>'
            +     '<div class="{{C_CARD_VALUE_SUIT}}">{{{suitContent}}}</div>'
            +   '</div>'
            +   '<div class="{{C_CARD_VALUE}} {{C_CARD_VALUE_BOTTOM}} {{C_CARD_UPSIDE_DOWN}}">'
            +     '<div class="{{C_CARD_VALUE_VALUE}}">{{{valueContent}}}</div>'
            +     '<div class="{{C_CARD_VALUE_SUIT}}">{{{suitContent}}}</div>'
            +   '</div>'
            +   '<div class="{{C_CARD_SUITS}} {{#image}}{{C_CARD_IMAGE}}{{/image}}">'
            +     '{{#image}}<img width="{{imageWidth}}" height="{{imageHeight}}" src="{{imagesBase}}{{card}}.png" />{{/image}}'
            +     '{{#1}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-1">{{{suitContent}}}</div>{{/1}}'
            +     '{{#2}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-2">{{{suitContent}}}</div>{{/2}}'
            +     '{{#3}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-3">{{{suitContent}}}</div>{{/3}}'
            +     '{{#4}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-4">{{{suitContent}}}</div>{{/4}}'
            +     '{{#5}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-5">{{{suitContent}}}</div>{{/5}}'
            +     '{{#6}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-6">{{{suitContent}}}</div>{{/6}}'
            +     '{{#7}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-7">{{{suitContent}}}</div>{{/7}}'
            +     '{{#8}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-8">{{{suitContent}}}</div>{{/8}}'
            +     '{{#9}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-9">{{{suitContent}}}</div>{{/9}}'
            +     '{{#10}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-10">{{{suitContent}}}</div>{{/10}}'
            +     '{{#11}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-11 {{C_CARD_UPSIDE_DOWN}}">{{{suitContent}}}</div>{{/11}}'
            +     '{{#12}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-12 {{C_CARD_UPSIDE_DOWN}}">{{{suitContent}}}</div>{{/12}}'
            +     '{{#13}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-13 {{C_CARD_UPSIDE_DOWN}}">{{{suitContent}}}</div>{{/13}}'
            +     '{{#14}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-14 {{C_CARD_UPSIDE_DOWN}}">{{{suitContent}}}</div>{{/14}}'
            +     '{{#15}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-15 {{C_CARD_UPSIDE_DOWN}}">{{{suitContent}}}</div>{{/15}}'
            +     '{{#16}}<div class="{{C_CARD_SUIT}} {{C_CARD_SUIT}}-16 {{C_CARD_UPSIDE_DOWN}}">{{{suitContent}}}</div>{{/16}}'
            +   '</div>'
            + '</div>',

        CARD_UNKNOWN_TEMPLATE: ''
            + '<div class="{{C_CARD_CARD}} {{C_CARD_UNKNOWN}}">'
            +   '<div class="{{C_CARD_COVER}}"></div>'
            + '</div>'

    });

    Y.Bridge.Card = Card;

}, "0", { requires: ["widget", "widget-child", "mustache"] });
