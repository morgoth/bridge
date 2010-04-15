class Ajax::TablesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board
  # caches_action :show, :cache_path => :show_cache_path.to_proc

  def show
    @table = Table.find(params[:id])
    @board = @table.boards.current
    respond_with(@table)
  end

  protected

  def show_cache_path
    current_user ? ajax_user_table_path(current_user, params[:id]) : ajax_table_path(params[:id])
  end
end
