class Ajax::TablesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board

  def show
    @table = Table.find(params[:id], :include => :players)
    @board = @table.boards.current
    respond_with(@table)
  end
end
