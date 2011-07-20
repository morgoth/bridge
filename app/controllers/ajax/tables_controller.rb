class Ajax::TablesController < Ajax::ApplicationController
  def show
    respond_with(TableSerializer.new(params[:id]))
  end
end
