YUI().use("table", "table-model", function (Y) {
    this.Y = Y;

    var tableWidget = new Y.Bridge.Table().render(),
        tableModel = new Y.Bridge.Model.Table({ id: 1 });

    tableModel.load({}, function (error, response) {
        if (!error) {
            Y.log(tableModel.generate());
            tableWidget.setAttrs(tableModel.generate());
        }
    });
});
