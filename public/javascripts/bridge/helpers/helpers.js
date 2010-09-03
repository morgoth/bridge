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
            return Y.ClassNameManager.getClassName("bridge", "card", "unknown");
        } else {
            return Y.ClassNameManager.getClassName("bridge", "card", card.toLowerCase());
        }
    };

    Y.Bridge.renderCard = function(card) {
        var suit, value,
            content = "",
            classNames = [
                Y.ClassNameManager.getClassName("bridge", "card")
            ];

        classNames.push(Y.Bridge.getCardClassName(card));

        if(card !== "") {
            suit = Y.Bridge.parseSuit(card),
            value = Y.Bridge.parseValue(card),
            content = Y.Bridge.renderSuit(suit) + Y.Bridge.renderValue(value);
            classNames.push(Y.ClassNameManager.getClassName("bridge", "card", suit.toLowerCase()));
        }

        return ''
            + '<button '
            +   'class="' + classNames.join(" ") + '" '
            +   'disabled="disabled" '
            +   'data-event="card" '
            +   'data-event-argument="' + card + '"'
            + '>'
            + content
            + '</button>';
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

}, "0", { requires: ["collection", "oop", "classnamemanager"] });
