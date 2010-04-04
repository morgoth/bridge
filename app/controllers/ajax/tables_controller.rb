class Ajax::TablesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board
  caches_action :show, :cache_path => :show_cache_path.to_proc

  def show
    @table = Table.find(params[:id])
    respond_with(@table)
  end

  protected

  def show_cache_path
    if current_user
      "users/#{current_user.id}/tables/#{params[:id]}"
    else
      "tables/#{params[:id]}"
    end
  end
end
