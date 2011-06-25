YUI.add("card", function (Y) {

    var Card = Y.Base.create("card", Y.Widget, [Y.WidgetChild], {

        BOUNDING_TEMPLATE : '<li></li>',
        CONTENT_TEMPLATE : '<div></div>',

        renderUI: function () {
            this._renderCard();
        },

        _renderCard: function () {
            // card cover
            this._coverNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("cover"));

            // card value (top)
            this._topNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("value")).addClass(this.getClassName("value", "top"));
            this._topValueNode = this._topNode.appendChild('<div>').addClass(this.getClassName("value", "value"));
            this._topSuitNode = this._topNode.appendChild('<div>').addClass(this.getClassName("value", "suit"));

            // card value (bottom)
            this._bottomNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("value")).addClass(this.getClassName("value", "bottom")).addClass(this.getClassName("upside", "down"));
            this._bottomValueNode = this._bottomNode.appendChild('<div>').addClass(this.getClassName("value", "value"));
            this._bottomSuitNode = this._bottomNode.appendChild('<div>').addClass(this.getClassName("value", "suit"));

            // card suits and image
            this._suitsNode = this.get("contentBox").appendChild('<div>').addClass(this.getClassName("suits"));
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
            this.get("contentBox").after("click", this._afterContentBoxClick, this);
        },

        _afterImageSizeChange: function (event) {
            this._syncImageSize(event.newVal);
        },

        _afterCardChange: function (event) {
            this._syncCard(event.newVal, event.prevVal);
        },

        _afterContentBoxClick: function (event) {
            event.preventDefault();

            if (!this.get("disabled")) {
                this.fire("card", this.get("card"));
            }
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

            if (Y.Lang.isString(prevSuit)) {
                this.get("contentBox").removeClass(this.getClassName("suit", prevSuit.toLowerCase()));
            }

            if (Y.Lang.isString(newSuit)) {
                this.get("contentBox").addClass(this.getClassName("suit", newSuit.toLowerCase()));
            }

            if (Y.Lang.isValue(newSuit) && Y.Lang.isValue(newValue)) {
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
                this._coverNode.show();

                this._suitsNode.hide();
                this._topNode.hide();
                this._bottomNode.hide();

                this._syncValue("");
                this._syncSuit("");
            }
        },

        _syncValue: function (value) {
            var content = value;

            if (value === "T") {
                content = "10";
            }

            Y.each([this._topValueNode, this._bottomValueNode], function (node) {
                node.setContent(content);
            });

            Y.each(this._suitNodes, function (node, i) {
                Y.Array.indexOf(Card.SUIT_ARRAYS[value] || [], i) === -1 ? node.hide() : node.show();
            }, this);
        },

        _syncSuit: function (suit) {
            Y.each(this._suitNodes.concat(this._topSuitNode, this._bottomSuitNode), function (node) {
                node.setContent(Card.SUITS[suit] || "");
            });
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

        },

        SUITS: {
            "C": "&clubs;",
            "D": "&diams;",
            "H": "&hearts;",
            "S": "&spades;"
        },

        SUIT_ARRAYS: {
            "2": [2, 15],
            "3": [2, 9, 15],
            "4": [1, 3, 14, 16],
            "5": [1, 3, 9, 14, 16],
            "6": [1, 3, 8, 10, 14, 16],
            "7": [1, 3, 5, 8, 10, 14, 16],
            "8": [1, 3, 6, 7, 11, 12, 14, 16],
            "9": [1, 3, 6, 7, 9, 11, 12, 14, 16],
            "T": [1, 3, 4, 6, 7, 11, 12, 13, 14, 16],
            "J": [1, 16],
            "Q": [1, 16],
            "K": [1, 16],
            "A": [9]
        }

    });

    Y.namespace("Bridge").Card = Card;

}, "0", { requires: ["widget", "widget-child", "collection"] });
