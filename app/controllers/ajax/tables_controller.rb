class Ajax::TablesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board

  def show
    @table = Table.find(params[:id])
    respond_with(@table)
  end
end
