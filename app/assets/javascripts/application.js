YUI().use("table", "table-model", function (Y) {
    this.Y = Y;

    tableWidget = new Y.Bridge.Table().render();
    tableModel = new Y.Bridge.Model.Table({ id: 1 });

    tableModel.load({}, function (error, response) {
        if (!error) {
            var data = tableModel.generate();
            Y.log(data);
            tableWidget.setAttrs(data);
        }
    });
});
