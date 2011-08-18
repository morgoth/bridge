YUI.add("helpers", function (Y) {

    Y.namespace("Bridge");

    Y.Bridge.DIRECTIONS = ["N", "E", "S", "W"];

    Y.Bridge.MODIFIERS = ["X", "XX"];

    Y.Bridge.LEVELS = [1, 2, 3, 4, 5, 6, 7];

    Y.Bridge.SUITS = ["C", "D", "H", "S"];

    Y.Bridge.CONTRACT_SUITS = Y.Bridge.SUITS.concat("NT");

    Y.Bridge.VALUES = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"];

    Y.Bridge.VULNERABILITIES = ["NONE", "NS", "EW", "BOTH"];

    Y.Bridge.CARDS = ["SA", "SK", "SQ", "SJ", "ST", "S9", "S8", "S7", "S6", "S5", "S4", "S3", "S2",
                      "HA", "HK", "HQ", "HJ", "HT", "H9", "H8", "H7", "H6", "H5", "H4", "H3", "H2",
                      "DA", "DK", "DQ", "DJ", "DT", "D9", "D8", "D7", "D6", "D5", "D4", "D3", "D2",
                      "CA", "CK", "CQ", "CJ", "CT", "C9", "C8", "C7", "C6", "C5", "C4", "C3", "C2"];

    Y.Bridge.CONTRACTS = ["1C", "1D", "1H", "1S", "1NT",
                          "2C", "2D", "2H", "2S", "2NT",
                          "3C", "3D", "3H", "3S", "3NT",
                          "4C", "4D", "4H", "4S", "4NT",
                          "5C", "5D", "5H", "5S", "5NT",
                          "6C", "6D", "6H", "6S", "6NT",
                          "7C", "7D", "7H", "7S", "7NT"];

    // SUITS
    Y.Bridge.makeContract = function (level, suit, modifiers) {
      // Modifiers are not required
      // TODO: Validation?
      modifiers = modifiers || "";
      return level + suit + modifiers;
    };

    Y.Bridge.isContractSuit = function (suit) {
        return Y.Array.indexOf(Y.Bridge.CONTRACT_SUITS, suit) !== -1;
    };

    Y.Bridge.suitPosition = function (suit) {
        return Y.Bridge.isContractSuit(suit) ? Y.Array.indexOf(Y.Bridge.CONTRACT_SUITS, suit) : undefined;
    };

    Y.Bridge.parseSuit = function (contract) {
        var matchData = contract && contract.match(new RegExp(Y.Bridge.SUITS.join("|")));

        return matchData ? matchData[0] : undefined;
    };

    Y.Bridge.parseContractSuit = function (contract) {
        var matchData = contract && contract.match(new RegExp(Y.Bridge.CONTRACT_SUITS.join("|")));

        return matchData ? matchData[0] : undefined;
    };

    Y.Bridge.parseLevel = function (contract) {
        return parseInt(contract, 10);
    };

    Y.Bridge.hasSuit = function (suit, cards) {
        return Y.Array.find(cards, function (card) {
            return Y.Bridge.parseSuit(card) === suit;
        }) !== null;
    };

    // DIRECTIONS

    Y.Bridge.directionPosition = function (direction) {
        return Y.Bridge.isDirection(direction) ? Y.Array.indexOf(Y.Bridge.DIRECTIONS, direction) : undefined;
    };

    Y.Bridge.isDirection = function (direction) {
        return Y.Array.indexOf(Y.Bridge.DIRECTIONS, direction) !== -1;
    };

    Y.Bridge.areSameSide = function (firstDirection, secondDirection) {
        return Y.Bridge.isDirection(firstDirection)
            && Y.Bridge.isDirection(secondDirection)
            && Y.Bridge.directionPosition(firstDirection) % 2 === Y.Bridge.directionPosition(secondDirection) % 2;
    };

    Y.Bridge.directionDistance = function (firstDirection, secondDirection) {
        var difference,
            firstPosition = Y.Bridge.directionPosition(firstDirection),
            secondPosition = Y.Bridge.directionPosition(secondDirection);

        if (Y.Bridge.isDirection(firstDirection) && Y.Bridge.isDirection(secondDirection)) {
            return (((secondPosition - firstPosition) % 4) + 4) % 4;
        } else {
            return undefined;
        }
    };

    // MODIFIERS

    Y.Bridge.isModifier = function (modifier) {
        return Y.Array.indexOf(Y.Bridge.MODIFIERS, modifier) !== -1;
    };

    // OTHER

    Y.Bridge.isContract = function (contract) {
        return new RegExp("^(" + Y.Bridge.CONTRACTS.join("|") + ")(X{1,2})?$").test(contract);
    };

    Y.Bridge.isLevel = function (level) {
        return /^\d+$/.test(level) && Y.Array.indexOf(Y.Bridge.LEVELS, parseInt(level, 10)) !== -1;
    };

    Y.Bridge.parseValue = function (card) {
        var matchData = card.match(new RegExp(Y.Bridge.VALUES.join("|")));

        return matchData ? matchData[0] : undefined;
    };

    Y.Bridge.parseModifiers = function (contract) {
        var matchData = contract.match(/X{1,2}/);

        return matchData ? matchData[0] : "";
    };

    Y.Bridge.isVulnerability = function (vulnerability) {
        return Y.Array.indexOf(Y.Bridge.VULNERABILITIES, vulnerability) !== -1;
    };

    Y.Bridge.valuePosition = function (value) {
        return Y.Array.indexOf(Y.Bridge.VALUES, value);
    };

}, "", { requires: [] });
