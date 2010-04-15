class Ajax::TablesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board

  def show
    @table = Table.find(params[:id], :include => :players)
    @board = @table.boards.current
    fresh_when :etag => [current_user, @table]
  end
end
