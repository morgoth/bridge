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

    Y.Bridge.bidPlayer = function(dealer, bids, bid) {
        var clonedBids = Y.clone(bids),
            dealerPosition = Y.Bridge.dealerPosition(dealer),
            bidPosition = Y.Array.indexOf(clonedBids.reverse(), bid);

        return Y.Bridge.DIRECTIONS[(dealerPosition + bidPosition) % 4];
    };

    Y.Bridge.lastContract = function(bids) {
        var clonedBids = Y.clone(bids);

        return Y.Array.find(clonedBids.reverse(), function(bid) {
            return Y.Array.indexOf(Y.Bridge.CONTRACTS, bid) !== -1;
        });
    };

    Y.Bridge.lastContractPlayer = function(dealer, bids) {
        var contract = Y.Bridge.lastContract(bids);

        return Y.Bridge.bidPlayer(dealer, bids, contract);
    };

    Y.Bridge.isLastContractDoubled = function(bids) {
        var contractIndex,
            clonedBids = Y.clone(bids),
            contract = Y.Bridge.lastContract(bids);
        contractIndex = Y.Array.indexOf(clonedBids, contract);

        return Y.Array.indexOf(clonedBids.splice(contractIndex), "X") !== -1;
    };

    Y.Bridge.isLastContractRedoubled = function(bids) {
        var contractIndex,
            clonedBids = Y.clone(bids),
            contract = Y.Bridge.lastContract(bids);
        contractIndex = Y.Array.indexOf(clonedBids, contract);

        return Y.Array.indexOf(clonedBids.splice(contractIndex), "XX") !== -1;
    };

    Y.Bridge.arePartners = function(firstPlayer, secondPlayer) {
        var firstPlayerIndex = Y.Array.indexOf(Y.Bridge.DIRECTIONS, firstPlayer),
            secondPlayerIndex = Y.Array.indexOf(Y.Bridge.DIRECTION, secondPlayer);

        return (firstPlayerIndex % 2) === (secondPlayerIndex % 2);
    };

    Y.Bridge.areOpponents = function(firstPlayer, secondPlayer) {
        return !Y.Bridge.arePartners(firstPlayer, secondPlayer);
    };

    Y.Bridge.biddingPlayer = function(dealer, bids) {
        var dealerPosition = Y.Array.indexOf(Y.Bridge.DIRECTIONS, dealer);

        return Y.Bridge.DIRECTIONS[(bids.length + dealerPosition) % 4];
    };


}, "0", { requires: ["collection", "oop"] });
