YUI.add("helpers-test", function (Y) {

    var isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;


    Y.namespace("Bridge.Test").Helpers = new Y.Test.Case({

        name: "Helpers Tests",

        testIsContractSuit: function () {
            isTrue(Y.Bridge.isContractSuit("C"));
            isTrue(Y.Bridge.isContractSuit("D"));
            isTrue(Y.Bridge.isContractSuit("H"));
            isTrue(Y.Bridge.isContractSuit("S"));
            isTrue(Y.Bridge.isContractSuit("NT"));

            isFalse(Y.Bridge.isContractSuit("X"));
        },

        testSuitPosition: function () {
            areSame(0, Y.Bridge.suitPosition("C"));
            areSame(1, Y.Bridge.suitPosition("D"));
            areSame(2, Y.Bridge.suitPosition("H"));
            areSame(3, Y.Bridge.suitPosition("S"));
            areSame(4, Y.Bridge.suitPosition("NT"));

            isUndefined(Y.Bridge.suitPosition("XX"));
        },

        testParseSuit: function () {
            areSame("C", Y.Bridge.parseSuit("1CXX"));
            areSame("D", Y.Bridge.parseSuit("5D"));
            areSame("H", Y.Bridge.parseSuit("2H"));
            areSame("S", Y.Bridge.parseSuit("6S"));

            isUndefined(Y.Bridge.parseSuit(""));
            isUndefined(Y.Bridge.parseSuit("X"));
            isUndefined(Y.Bridge.parseSuit("NT"));
        },

        testParseContractSuit: function () {
            areSame("C", Y.Bridge.parseContractSuit("1CXX"));
            areSame("D", Y.Bridge.parseContractSuit("5D"));
            areSame("H", Y.Bridge.parseContractSuit("2H"));
            areSame("S", Y.Bridge.parseContractSuit("6S"));
            areSame("NT", Y.Bridge.parseContractSuit("7NTX"));

            isUndefined(Y.Bridge.parseContractSuit(""));
            isUndefined(Y.Bridge.parseContractSuit("X"));
        },

        testDirectionPosition: function () {
            areSame(0, Y.Bridge.directionPosition("N"));
            areSame(1, Y.Bridge.directionPosition("E"));
            areSame(2, Y.Bridge.directionPosition("S"));
            areSame(3, Y.Bridge.directionPosition("W"));

            isUndefined(Y.Bridge.directionPosition(""));
        },

        testIsDirection: function () {
            isTrue(Y.Bridge.isDirection("N"));
            isTrue(Y.Bridge.isDirection("E"));
            isTrue(Y.Bridge.isDirection("S"));
            isTrue(Y.Bridge.isDirection("W"));

            isFalse(Y.Bridge.isDirection("A"));
        },

        testAreSameSide: function () {
            isTrue(Y.Bridge.areSameSide("E", "W"));
            isTrue(Y.Bridge.areSameSide("W", "E"));
            isTrue(Y.Bridge.areSameSide("N", "S"));
            isTrue(Y.Bridge.areSameSide("S", "N"));

            isFalse(Y.Bridge.areSameSide("E", "N"));
            isFalse(Y.Bridge.areSameSide("S", "W"));
            isFalse(Y.Bridge.areSameSide("X", "X"));
        },

        testDirectionDistance: function () {
            areSame(0, Y.Bridge.directionDistance("N", "N"));
            areSame(1, Y.Bridge.directionDistance("N", "E"));
            areSame(2, Y.Bridge.directionDistance("N", "S"));
            areSame(3, Y.Bridge.directionDistance("N", "W"));

            areSame(0, Y.Bridge.directionDistance("E", "E"));
            areSame(1, Y.Bridge.directionDistance("E", "S"));
            areSame(2, Y.Bridge.directionDistance("E", "W"));
            areSame(3, Y.Bridge.directionDistance("E", "N"));

            areSame(0, Y.Bridge.directionDistance("S", "S"));
            areSame(1, Y.Bridge.directionDistance("S", "W"));
            areSame(2, Y.Bridge.directionDistance("S", "N"));
            areSame(3, Y.Bridge.directionDistance("S", "E"));

            areSame(0, Y.Bridge.directionDistance("W", "W"));
            areSame(1, Y.Bridge.directionDistance("W", "N"));
            areSame(2, Y.Bridge.directionDistance("W", "E"));
            areSame(3, Y.Bridge.directionDistance("W", "S"));

            isUndefined(Y.Bridge.directionDistance("X", "X"));
            isUndefined(Y.Bridge.directionDistance("E", "X"));
            isUndefined(Y.Bridge.directionDistance("X", "N"));
        },

        testIsModifier: function () {
            isTrue(Y.Bridge.isModifier("X"));
            isTrue(Y.Bridge.isModifier("XX"));

            isFalse(Y.Bridge.isModifier("PASS"));
            isFalse(Y.Bridge.isModifier("XXX"));
            isFalse(Y.Bridge.isModifier("1C"));
        },

        testIsContract: function () {
            isTrue(Y.Bridge.isContract("1C"));
            isTrue(Y.Bridge.isContract("1CX"));
            isTrue(Y.Bridge.isContract("1CXX"));

            isTrue(Y.Bridge.isContract("2D"));
            isTrue(Y.Bridge.isContract("2DX"));
            isTrue(Y.Bridge.isContract("2DXX"));

            isTrue(Y.Bridge.isContract("3H"));
            isTrue(Y.Bridge.isContract("3HX"));
            isTrue(Y.Bridge.isContract("3HXX"));

            isTrue(Y.Bridge.isContract("4S"));
            isTrue(Y.Bridge.isContract("4SX"));
            isTrue(Y.Bridge.isContract("4SXX"));

            isTrue(Y.Bridge.isContract("5NT"));
            isTrue(Y.Bridge.isContract("5NTX"));
            isTrue(Y.Bridge.isContract("5NTXX"));

            isFalse(Y.Bridge.isContract(""));
            isFalse(Y.Bridge.isContract("1"));
            isFalse(Y.Bridge.isContract("NT"));
            isFalse(Y.Bridge.isContract("X"));
            isFalse(Y.Bridge.isContract("XX"));
            isFalse(Y.Bridge.isContract("8NT"));
            isFalse(Y.Bridge.isContract("1CH"));
            isFalse(Y.Bridge.isContract("HXX"));
            isFalse(Y.Bridge.isContract("1CXXX"));
        },

        testIsLevel: function () {
            isTrue(Y.Bridge.isLevel("1"));
            isTrue(Y.Bridge.isLevel("2"));
            isTrue(Y.Bridge.isLevel("3"));
            isTrue(Y.Bridge.isLevel("4"));
            isTrue(Y.Bridge.isLevel("5"));
            isTrue(Y.Bridge.isLevel("6"));
            isTrue(Y.Bridge.isLevel("7"));

            isTrue(Y.Bridge.isLevel(1));
            isTrue(Y.Bridge.isLevel(7));

            isFalse(Y.Bridge.isLevel(""));
            isFalse(Y.Bridge.isLevel(0));
            isFalse(Y.Bridge.isLevel("X"));
            isFalse(Y.Bridge.isLevel("1C"));
        },

        testParseValue: function () {
            areSame("A", Y.Bridge.parseValue("HA"));
            areSame("Q", Y.Bridge.parseValue("SQ"));
            areSame("T", Y.Bridge.parseValue("DT"));
            areSame("4", Y.Bridge.parseValue("C4"));

            isUndefined(Y.Bridge.parseValue(""));
            isUndefined(Y.Bridge.parseValue("1C"));
        },

        testParseModifiers: function () {
            areSame("", Y.Bridge.parseModifiers("1C"));
            areSame("X", Y.Bridge.parseModifiers("4NTX"));
            areSame("XX", Y.Bridge.parseModifiers("7SXX"));

            areSame("XX", Y.Bridge.parseModifiers("7NTXXX"));
            areSame("", Y.Bridge.parseModifiers(""));
        },

        testIsVulnerability: function () {
            isTrue(Y.Bridge.isVulnerability("NONE"));
            isTrue(Y.Bridge.isVulnerability("NS"));
            isTrue(Y.Bridge.isVulnerability("EW"));
            isTrue(Y.Bridge.isVulnerability("BOTH"));

            isFalse(Y.Bridge.isVulnerability("SN"));
            isFalse(Y.Bridge.isVulnerability("WE"));
            isFalse(Y.Bridge.isVulnerability(""));
        }

    });

}, "", { requires: ["test", "helpers"] });

