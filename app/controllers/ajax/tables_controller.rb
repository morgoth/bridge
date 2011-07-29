class Ajax::TablesController < Ajax::ApplicationController
  skip_before_filter :fetch_table, :fetch_board

  def show
    respond_with(TableSerializer.new(params[:id]))
  end
end
