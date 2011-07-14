YUI.add("passbox", function(Y){

    var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [Y.WidgetChild], {
        initializer: function () {
            this._addChildren();
        },

        renderUI: function () {
            this._renderPassBox();
        },

        _addChildren: function () {
            this.add(new Y.Button({ label: 'pass' }));
            this.add(new Y.Button({ label: 'x' }));
            this.add(new Y.Button({ label: 'xx' }));
        },

        _renderPassBox: function () {
            this.get('contentBox').append(Y.Node.create(''));
        },

    }, {
        NAME: "passbox",
        ATTRS: {
            label: {
                value: ''
            },
            enableButtons: {
                value: {
                    'x': true,
                    'xx': true
                }
            }
        }
    });

    Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
