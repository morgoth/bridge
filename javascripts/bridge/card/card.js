YUI.add("card", function (Y) {

    var getClassName = Y.ClassNameManager.getClassName,
        DOT = ".";

    var Card = Y.Base.create("card", Y.Widget, [Y.WidgetChild], {

        BOUNDING_TEMPLATE : "<li></li>",
        CONTENT_TEMPLATE : "<div></div>",

        renderUI: function () {
            this._renderCard();
        },

        _renderCard: function () {
            this._cardNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("card"));

            // card cover
            this._coverNode = this._cardNode.appendChild('<div>').addClass(this.getClassName("cover"));

            // card value (top)
            this._topNode = this._cardNode.appendChild('<div>').addClass(this.getClassName("value")).addClass(this.getClassName("value", "top"));
            this._topValueNode = this._topNode.appendChild('<div>').addClass(this.getClassName("value", "value"));
            this._topSuitNode = this._topNode.appendChild('<div>').addClass(this.getClassName("value", "suit"));

            // card value (bottom)
            this._bottomNode = this._cardNode.appendChild('<div>').addClass(this.getClassName("value")).addClass(this.getClassName("value", "bottom")).addClass(this.getClassName("upside", "down"));
            this._bottomValueNode = this._bottomNode.appendChild('<div>').addClass(this.getClassName("value", "value"));
            this._bottomSuitNode = this._bottomNode.appendChild('<div>').addClass(this.getClassName("value", "suit"));

            // card suits and image
            this._suitsNode = this._cardNode.appendChild('<div>').addClass(this.getClassName("suits"));
            this._imageNode = this._suitsNode.appendChild('<img>').addClass(this.getClassName("image"));
            this._suitNodes = [];

            for (var i = 1; i < 17; i++) {
                this._suitNodes[i] = this._suitsNode.appendChild('<div>').addClass(this.getClassName("suit")).addClass(this.getClassName("suit", i));
                if (i > 10) {
                    this._suitNodes[i].addClass(this.getClassName("upside", "down"));
                }
            }
        },

        bindUI: function () {
            this.after("imageSizeChange", this._afterImageSizeChange);
            this.after("cardChange", this._afterCardChange);
        },

        _afterImageSizeChange: function (event) {
            this._syncImageSize(event.newVal);
        },

        _afterCardChange: function (event) {
            this._syncCard(event.newVal, event.prevVal);
        },

        syncUI: function () {
            this._syncImageSize(this.get("imageSize"));
            this._syncCard(this.get("card"), "");
        },

        _syncImageSize: function (size) {
            this._imageNode.setAttrs({
                width: size[0],
                height: size[1]
            });
        },

        _syncCard: function (newCard, prevCard) {
            var prevSuit = prevCard[0],
                prevValue = prevCard[1],
                newSuit = newCard[0],
                newValue = newCard[1];

            if (Y.Lang.isValue(newSuit) && Y.Lang.isValue(newValue)) {
                this._cardNode.replaceClass(this.getClassName("suit", prevSuit), this.getClassName("suit", newSuit));

                this._coverNode.hide();

                this._suitsNode.show();
                this._topNode.show();
                this._bottomNode.show();

                this._syncValue(newValue);
                this._syncSuit(newSuit);

                if (newValue === "J" || newValue === "Q" || newValue === "K") {
                    this._imageNode.set("src", this.get("imagesBase") + newCard.toLowerCase() + ".png").show();
                } else {
                    this._imageNode.removeAttribute("src").hide();
                }

            } else {
                this._cardNode.removeClass(this.getClassName("suit", prevSuit));

                this._coverNode.show();

                this._suitsNode.hide();
                this._topNode.hide();
                this._bottomNode.hide();

                this._syncValue("");
                this._syncSuit("");
            }
        },

        _syncValue: function (value) {
            var content = value,
                suitsArray = this._suitsArray(value);

            if (value === "T") {
                content = "10";
            }

            Y.each([this._topValueNode, this._bottomValueNode], function (node) {
                node.setContent(content);
            });

            Y.each(this._suitNodes, function (node, i) {
                Y.Array.indexOf(suitsArray, i) !== -1 ? node.show() : node.hide();
            }, this);
        },

        _syncSuit: function (suit) {
            var content;

            switch(suit) {
            case "C":
                content = "&clubs;";
                break;
            case "D":
                content = "&diams;";
                break;
            case "H":
                content = "&hearts;";
                break;
            case "S":
                content = "&spades;";
                break;
            default:
                content = "";
                break;
            }

            Y.each(this._suitNodes.concat(this._topSuitNode, this._bottomSuitNode), function (node) {
                node.setContent(content);
            });
        },

        _suitsArray: function (value) {
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
        }

    }, {

        ATTRS: {

            card: {
                value: ""
            },

            imagesBase: {
                value: "/assets/bridge/card/assets/skins/sam/"
            },

            imageSize: {
                value: [53, 90]
            }

        }

    });

    Y.namespace("Bridge").Card = Card;

}, "0", { requires: ["widget", "widget-child", "collection"] });
