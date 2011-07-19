class Ajax::TablesController < Ajax::BaseController
  # skip_before_filter :fetch_table, :fetch_board

  def show
    respond_with(TableSerializer.new(params[:id]).to_json)
  end
end
