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

            });

            contentBox.set("innerHTML", html);
        },

        bindUI: function() {

        },

        syncUI: function() {

        }

    }, {

        NAME: "tricks",

        ATTRS: {

            host: {

            }

        },

        MAIN_TEMPLATE: ''
            + '<ul class="{{cardsCN}}"></ul>'
            + '<div class="{{barCN}}">'
            +   '<div class="{{directionCN}}">{{direction}}</div>'
            +   '<div class="{{nameCN}}">{{name}}</div>'
            + '</div>',

        TRICKS_TEMPLATE: ''
            + '{{#cards}}'
            +   '<li class="{{classNames}}">'
            +     '{{{card}}}'
            +   '</li>'
            + '{{/cards}}'

    });

    Y.Bridge.Tricks = Tricks;

}, "0", { requires: ["widget", "collection", "mustache"] });
