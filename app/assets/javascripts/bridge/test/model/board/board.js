YUI.add("board-model-test", function (Y) {

    var isTrue = Y.Assert.isTrue,
        isFalse = Y.Assert.isFalse,
        isUndefined = Y.Assert.isUndefined,
        areSame = Y.Assert.areSame;


    Y.namespace("Bridge.Test.Model").Board = new Y.Test.Case({

        name: "Board Tests",

        setUp: function () {
            this.board = new Y.Bridge.Model.Board();
        }

    });

}, "", { requires: ["test", "board-model"] });

