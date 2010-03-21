YUI.add("helpers", function(Y) {

    Y.namespace("Bridge");

    Y.Bridge.DIRECTIONS = ["N", "E", "S", "W"];

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

    Y.Bridge.isContract = function(contract) {
        return Y.Array.indexOf(Y.Bridge.CONTRACTS, contract) !== -1;
    };

    Y.Bridge.isLevel = function(level) {
        return Y.Array.indexOf(Y.Bridge.CONTRACTS, parseInt(level)) !== -1;
    };

}, "0", { requires: ["collection", "oop"] });
