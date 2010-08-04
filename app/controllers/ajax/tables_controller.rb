class Ajax::TablesController < Ajax::BaseController
  skip_before_filter :fetch_table, :fetch_board

  def show
    @table = Table.find(params[:id], :include => :players)
    @serializer = Serializer.new(@table)
    render :locals => {:serializer => @serializer, :user => current_user}
  end
end
