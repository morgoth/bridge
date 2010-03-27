YUI.add("helpers", function(Y) {

    Y.namespace("Bridge");

    Y.Bridge.DIRECTIONS = ["N", "E", "S", "W"];

    Y.Bridge.MODIFIERS = ["X", "XX"];

    Y.Bridge.LEVELS = [1, 2, 3, 4, 5, 6, 7];

    Y.Bridge.SUITS = ["C", "D", "H", "S", "NT"];

    Y.Bridge.CONTRACTS = Y.Array.reduce(Y.Bridge.LEVELS, [], function(result, level) {
        return result.concat(Y.Array.map(Y.Bridge.SUITS, function(suit) {
            return level + suit;
        }));
    });

    Y.Bridge.dealerPosition = function(dealer) {
        return Y.Array.indexOf(Y.Bridge.DIRECTIONS, dealer);
    };

    Y.Bridge.isModifier = function(modifier) {
        return Y.Array.indexOf(Y.Bridge.MODIFIERS, modifier) !== -1;
    };

    Y.Bridge.isContract = function(contract) {
        return Y.Array.indexOf(Y.Bridge.CONTRACTS, contract) !== -1;
    };

    Y.Bridge.isLevel = function(level) {
        return Y.Array.indexOf(Y.Bridge.LEVELS, parseInt(level)) !== -1;
    };

    Y.Bridge.isDirection = function(direction) {
        return Y.Array.indexOf(Y.Bridge.DIRECTIONS, direction) !== -1;
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

    Y.Bridge.parseSuit = function(contract) {
        return contract.match(new RegExp(Y.Bridge.SUITS.join("|")))[0];
    };

}, "0", { requires: ["collection", "oop", "classnamemanager"] });
