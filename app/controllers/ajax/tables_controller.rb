class Ajax::TablesController < Ajax::BaseController
  def show
    @table = Table.find(params[:id])
    respond_with(@table)
  end
end
