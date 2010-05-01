YUI.add("tricks", function(Y) {

    Y.namespace("Bridge");

    function Tricks() {
        Tricks.superclass.constructor.apply(this, arguments);
    }

    Y.extend(Tricks, Y.Widget, {

        renderUI: function() {
            this._renderMainTemplate();
        },

        _renderMainTemplate: function() {
            var html,
                contentBox = this.get("contentBox");

            html = Y.mustache(Tricks.MAIN_TEMPLATE, {
                tricksCN: this.getClassName("tricks"),
                barCN: this.getClassName("bar"),
                contract: this.get("contract"),
                contractCN: this.getClassName("contract"),
                declarer: this.get("declarer"),
                declarerCN: this.getClassName("declarer"),
                resultNS: this.get("resultNS"),
                resultNSCN: this.getClassName("result-ns"),
                resultEW: this.get("resultEW"),
                resultEWCN: this.getClassName("result-ew")
            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {
            this.after("contractChange", this._afterContractChange);
            this.after("declarerChange", this._afterDeclarerChange);
            this.after("resultNSChange", this._afterResultNSChange);
            this.after("resultEWChange", this._afterResultEWChange);
            this.after("tricksChange", this._afterTricksChange);
        },

        _afterContractChange: function(event) {
            this._uiSetContract(event.newVal);
        },

        _afterDeclarerChange: function(event) {
            this._uiSetDeclarer(event.newVal);
        },

        _afterResultNSChange: function(event) {
            this._uiSetResultNS(event.newVal);
        },

        _afterResultEWChange: function(event) {
            this._uiSetResultEW(event.newVal);
        },

        _afterTricksChange: function(event) {
            this._uiSetTricks(event.newVal);
        },

        syncUI: function() {

        },

        _uiSetContract: function(contract) {
            var contractNode,
                contractCN = this.getClassName("contract"),
                contentBox = this.get("contentBox");
            contractNode = contentBox.one("." + contractCN);

            contractNode.set("innerHTML", Y.Bridge.renderContract(contract));
        },

        _uiSetDeclarer: function(declarer) {
            var declarerNode,
                declarerCN = this.getClassName("declarer"),
                contentBox = this.get("contentBox");
            declarerNode = contentBox.one("." + declarerCN);

            declarerNode.set("innerHTML", declarer);
        },

        _uiSetResultNS: function(resultNS) {
            var resultNSNode,
                resultNSCN = this.getClassName("result-ns"),
                contentBox = this.get("contentBox");
            resultNSNode = contentBox.one("." + resultNSCN);

            resultNSNode.set("innerHTML", "NS " + resultNS);
        },

        _uiSetResultEW: function(resultEW) {
            var resultEWNode,
                resultEWCN = this.getClassName("result-ew"),
                contentBox = this.get("contentBox");
            resultEWNode = contentBox.one("." + resultEWCN);

            resultEWNode.set("innerHTML", "EW " + resultEW);
        },

        _uiSetTricks: function(tricks) {
            var tricksHtml, tricksData, tricksNode,
                player = this.get("player"),
                contentBox = this.get("contentBox");
            tricksData = Y.Array.map(tricks, function(trick) {
                var classNames = [
                    this.getClassName("trick")
                ];

                if(Y.Bridge.isSameSide(player, trick.winner)) {
                    classNames.push(this.getClassName("trick", "won"));
                } else {
                    classNames.push(this.getClassName("trick", "lost"));
                }

                return {
                    classNames: classNames.join(" ")
                };
            }, this);
            tricksNode = contentBox.one("." + this.getClassName("tricks"));

            tricksHtml = Y.mustache(Tricks.TRICKS_TEMPLATE, { tricks: tricksData });
            tricksNode.set("innerHTML", tricksHtml);
        }

    }, {

        NAME: "tricks",

        ATTRS: {

            host: {

            },

            contract: {
                // FIXME: the contract contains modifiers (e.g. 5DXX)
                // validator: Y.Bridge.isContract
            },

            declarer: {
                validator: Y.Bridge.isDirection
            },

            resultNS: {
                validator: Y.Lang.isNumber
            },

            resultEW: {
                validator: Y.Lang.isNumber
            },

            tricks: {
                validator: Y.Lang.isArray
            },

            player: {
                setter: function(player) {
                    return Y.Bridge.isDirection(player) ? player : "S";
                },
                value: "S"
            }

        },

        MAIN_TEMPLATE: ''
            + '<ul class="{{tricksCN}}"></ul>'
            + '<div class="{{barCN}}">'
            +   '<div class="{{contractCN}}">{{contract}}</div>'
            +   '<div class="{{declarerCN}}">{{declarer}}</div>'
            +   '<div class="{{resultEWCN}}">EW {{resultEW}}</div>'
            +   '<div class="{{resultNSCN}}">NS {{resultNS}}</div>'
            + '</div>',

        TRICKS_TEMPLATE: ''
            + '{{#tricks}}'
            +   '<li>'
            +     '<button class="{{classNames}}">&nbsp;</button>'
            +   '</li>'
            + '{{/tricks}}'

    });

    Y.Bridge.Tricks = Tricks;

}, "0", { requires: ["widget", "collection", "mustache", "helpers"] });
