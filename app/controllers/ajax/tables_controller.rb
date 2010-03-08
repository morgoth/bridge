class Ajax::TablesController < Ajax::BaseController
  def show
    @table = Table.find(params[:id])
    respond_with(@table)
  end

  protected

  def fetch_table
    @table = Table.find(params[:id])
  end
end
