YUI.add("passbox", function(Y){
  // Fires pressed button name (pass, x, xx)
  var PassBox = Y.Base.create("passbox", Y.ButtonGroup, [Y.WidgetChild], {
    initializer: function () {
      this._addChildren();
    },

    renderUI: function () {
      this._renderPassBox();
    },

    syncUI: function () {
      this.each(function(button){
        button.set("enabled",
                   this.get("enableButtons." + button.get("name")));
      }, this);
    },

    bindUI: function () {
      this.on("button:press", function (e) {
        this.fire(e.target.get("name"));
      });
    },

    _addChildren: function () {
      var buttons = {
        pass: new Y.Button({ label: "pass" }),
        x: new Y.Button({ label: "x" }),
        xx: new Y.Button({ label: "xx" })
      };

      // Adding buttons and assigning them names
      Y.each(buttons, function(button, name){
        button.set("name", name);
        this.add(button);
      }, this);

    },

    _renderPassBox: function () {

    }

  }, {
    NAME: "passbox",
    ATTRS: {
      label: {
        value: ""
      },
      enableButtons: {
        value: {
          "pass": true,
          "x": false,
          "xx": true
        }
      }
    }
  });

  Y.namespace("Bridge").PassBox = PassBox;

}, "0", { requires: ["gallery-button", "gallery-button-group"] });
