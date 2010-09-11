YUI.add("helpers", function(Y) {

    Y.namespace("Bridge");

    Y.Bridge.DIRECTIONS = ["N", "E", "S", "W"];

    Y.Bridge.MODIFIERS = ["X", "XX"];

    Y.Bridge.LEVELS = [1, 2, 3, 4, 5, 6, 7];

    Y.Bridge.SUITS = ["C", "D", "H", "S", "NT"];

    Y.Bridge.VALUES = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"];

    Y.Bridge.VULNERABILITIES = ["NONE", "NS", "EW", "BOTH"];

    Y.Bridge.CONTRACTS = Y.Array.reduce(Y.Bridge.LEVELS, [], function(result, level) {
        return result.concat(Y.Array.map(Y.Bridge.SUITS, function(suit) {
            return level + suit;
        }));
    });

    Y.Bridge.CARD_TEMPLATE = ''
        + '<button class="card card-{{suit}} card-{{card}}">'
        +   '<span class="card-content">'
        +     '<span class="card-value card-value-top">'
        +       '<span class="card-value-value">{{value}}</span>'
        +       '<span class="card-value-suit">&{{suit}};</span>'
        +     '</span>'
        +     '<span class="card-value card-value-bottom card-upside-down">'
        +       '<span class="card-value-value">{{value}}</span>'
        +       '<span class="card-value-suit">&{{suit}};</span>'
        +     '</span>'
        +     '<span class="card-suits {{#image}}card-image{{/image}}">'
        +       '{{#image}}<img width="48" height="90" src="/images/cards/{{card}}.png" />{{/image}}'
        +       '{{#1}}<span class="card-suit card-suit-1">&{{suit}};</span>{{/1}}'
        +       '{{#2}}<span class="card-suit card-suit-2">&{{suit}};</span>{{/2}}'
        +       '{{#3}}<span class="card-suit card-suit-3">&{{suit}};</span>{{/3}}'
        +       '{{#4}}<span class="card-suit card-suit-4">&{{suit}};</span>{{/4}}'
        +       '{{#5}}<span class="card-suit card-suit-5">&{{suit}};</span>{{/5}}'
        +       '{{#6}}<span class="card-suit card-suit-6">&{{suit}};</span>{{/6}}'
        +       '{{#7}}<span class="card-suit card-suit-7">&{{suit}};</span>{{/7}}'
        +       '{{#8}}<span class="card-suit card-suit-8">&{{suit}};</span>{{/8}}'
        +       '{{#9}}<span class="card-suit card-suit-9">&{{suit}};</span>{{/9}}'
        +       '{{#10}}<span class="card-suit card-suit-10 card-upside-down">&{{suit}};</span>{{/10}}'
        +       '{{#11}}<span class="card-suit card-suit-11 card-upside-down">&{{suit}};</span>{{/11}}'
        +       '{{#12}}<span class="card-suit card-suit-12 card-upside-down">&{{suit}};</span>{{/12}}'
        +       '{{#13}}<span class="card-suit card-suit-13 card-upside-down">&{{suit}};</span>{{/13}}'
        +       '{{#14}}<span class="card-suit card-suit-14 card-upside-down">&{{suit}};</span>{{/14}}'
        +       '{{#15}}<span class="card-suit card-suit-15 card-upside-down">&{{suit}};</span>{{/15}}'
        +     '</span>'
        +   '</span>'
        + '</button>';

    // SUITS

    Y.Bridge.isSuit = function(suit) {
        return Y.Array.indexOf(Y.Bridge.SUITS, suit) !== -1;
    };

    Y.Bridge.suitPosition = function(suit) {
        return Y.Bridge.isSuit(suit) ? Y.Array.indexOf(Y.Bridge.SUITS, suit) : undefined;
    };

    Y.Bridge.parseSuit = function(contract) {
        var matchData = contract.match(new RegExp(Y.Bridge.SUITS.join("|")));

        return matchData ? matchData[0] : undefined;
    };

    Y.Bridge.hasSuit = function(suit, cards) {
        return Y.Array.find(cards, function(card) {
            return Y.Bridge.parseSuit(card) === suit;
        }) !== null;
    };

    // DIRECTIONS

    Y.Bridge.directionPosition = function(direction) {
        return Y.Bridge.isDirection(direction) ? Y.Array.indexOf(Y.Bridge.DIRECTIONS, direction) : undefined;
    };
    Y.Bridge.dealerPosition = Y.Bridge.directionPosition; // TODO: remove calls - DEPRECATED

    Y.Bridge.isDirection = function(direction) {
        return Y.Array.indexOf(Y.Bridge.DIRECTIONS, direction) !== -1;
    };

    Y.Bridge.areSameSide = function(firstDirection, secondDirection) {
        return Y.Bridge.isDirection(firstDirection)
            && Y.Bridge.isDirection(secondDirection)
            && Y.Bridge.directionPosition(firstDirection) % 2 === Y.Bridge.directionPosition(secondDirection) % 2;
    };
    Y.Bridge.isSameSide = Y.Bridge.areSameSide; // TODO: remove calls - DEPRECATED

    Y.Bridge.directionDistance = function(firstDirection, secondDirection) {
        var difference,
            firstPosition = Y.Bridge.directionPosition(firstDirection),
            secondPosition = Y.Bridge.directionPosition(secondDirection);

        if(Y.Bridge.isDirection(firstDirection) && Y.Bridge.isDirection(secondDirection)) {
            difference = secondPosition - firstPosition;

            if(difference < 0) {
                difference += 4;
            }

            return difference % 4;
        } else {
            return undefined;
        }
    };

    // MODIFIERS

    Y.Bridge.isModifier = function(modifier) {
        return Y.Array.indexOf(Y.Bridge.MODIFIERS, modifier) !== -1;
    };

    Y.Bridge.isContract = function(contract) {
        return new RegExp("^(" + Y.Bridge.CONTRACTS.join("|") + ")(X{1,2})?$").test(contract);
    };

    Y.Bridge.isLevel = function(level) {
        return /^\d+$/.test(level) && Y.Array.indexOf(Y.Bridge.LEVELS, parseInt(level)) !== -1;
    };

    Y.Bridge.renderBid = function(bid) {
        var content, level, suit,
            className = Y.ClassNameManager.getClassName("bridge", "bid", bid.toLowerCase());

        switch(bid) {
        case "PASS":
            content = "Pass";
            break;
        case "X":
            content = "Dbl";
            break;
        case "XX":
            content = "Rdbl";
            break;
        default:
            level = parseInt(bid);
            suit = Y.Bridge.parseSuit(bid);
            content = level.toString() + Y.Bridge.renderSuit(suit);
            break;
        }

        return '<span class="' + className + '">' + content + '</span>';
    };

    Y.Bridge.renderContract = function(contract) {
        var content, level, suit, modifiers,
            className = Y.ClassNameManager.getClassName("bridge", "contract", contract.toLowerCase());
        level = parseInt(contract);
        suit = Y.Bridge.parseSuit(contract);
        modifiers = Y.Bridge.parseModifiers(contract);
        content = level.toString() + Y.Bridge.renderSuit(suit) + modifiers;

        return '<span class="' + className + '">' + content + '</span>';
    };

    Y.Bridge.renderSuit = function(suit) {
        var content,
            className = Y.ClassNameManager.getClassName("bridge", "suit", suit.toLowerCase());

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
            content = "NT";
            break;
        }

        return '<span class="' + className + '">' + content + '</span>';
    };

    Y.Bridge.renderValue = function(value) {
        var className = Y.ClassNameManager.getClassName("bridge", "value", value.toLowerCase());

        if(value === "T") {
            value = "10";
        }

        return '<span class="' + className + '">' + value + '</span>';
    };

    Y.Bridge.getCardClassName = function(card) {
        if(card === "") {
            // return Y.ClassNameManager.getClassName("card", "unknown");
            return "card-unknown";
        } else {
            // return Y.ClassNameManager.getClassName("card", card.toLowerCase());
            return "card-" + card.toLowerCase();
        }
    };

    Y.Bridge.renderCard = function(card) {
        var suit, value, suits,
            cardData = {};

        if(card === "") {
            return '<button class="card card-unknown"><span class="card-content"></span></button>';
        } else {
            suit = Y.Bridge.parseSuit(card);
            value = Y.Bridge.parseValue(card);

            cardData.card = card.toLowerCase();

            if(value === "T") {
                cardData.value = "10";
            } else {
                cardData.value = value;
            }

            switch(suit) {
            case "C":
                cardData.suit = "clubs";
                break;
            case "D":
                cardData.suit = "diams";
                break;
            case "H":
                cardData.suit = "hearts";
                break;
            case "S":
                cardData.suit = "spades";
                break;
            }

            switch(value) {
            case "A":
                suits = [8];
                break;
            case "2":
                suits = [2, 14];
                break;
            case "3":
                suits = [2, 8, 14];
                break;
            case "4":
                suits = [1, 3, 13, 15];
                break;
            case "5":
                suits = [1, 3, 8, 13, 15];
                break;
            case "6":
                suits = [1, 3, 7, 9, 13, 15];
                break;
            case "7":
                suits = [1, 3, 4, 7, 9, 13, 15];
                break;
            case "8":
                suits = [1, 3, 5, 6, 10, 11, 13, 15];
                break;
            case "9":
                suits = [1, 3, 5, 6, 8, 10, 11, 13, 15];
                break;
            case "T":
                suits = [1, 3, 4, 5, 6, 10, 11, 12, 13, 15];
                break;
            case "J":
                suits = [1, 15];
                cardData.image = true;
                break;
            case "Q":
                suits = [1, 15];
                cardData.image = true;
                break;
            case "K":
                suits = [1, 15];
                cardData.image = true;
                break;
            }

            Y.each(suits, function(suit) {
                cardData[suit] = true;
            });

            return Y.mustache(Y.Bridge.CARD_TEMPLATE, cardData);
        }
    };

    Y.Bridge.parseValue = function(card) {
        var matchData = card.match(new RegExp(Y.Bridge.VALUES.join("|")));

        return matchData ? matchData[0] : undefined;
    };

    Y.Bridge.parseModifiers = function(contract) {
        var matchData = contract.match(/X{1,2}/);

        return matchData ? matchData[0] : "";
    };

    Y.Bridge.isVulnerability = function(vulnerability) {
        return Y.Array.indexOf(Y.Bridge.VULNERABILITIES, vulnerability) !== -1;
    };

}, "0", { requires: ["collection", "oop", "classnamemanager", "mustache"] });
