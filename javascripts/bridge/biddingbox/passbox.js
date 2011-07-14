YUI.add("passbox", function(Y){

    var PassBox = Y.Base.create("passbox", Y.Widget, [Y.WidgetParent], {
        initializer: function () {
            this._addChildren();
        },

        // renderUI: function () {
        //     this._renderPassBox();
        // },

        _addChildren: function () {
            this.add(new Y.Button({ label: 'pass' }));
        },

        _renderPassBox: function () {
            this.get('contentBox').append(Y.Node.create(
                '<div>passbox</div>'
            ));
        },

    }, {
        NAME: "passbox",
        ATTRS: {
            label: {
                value: 'Pass-label'
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
