class Ajax::BidsController < Ajax::BaseController
  cache_sweeper :table_sweeper

  def create
    @bid = @board.bids.build(params[:bid])
    @bid.user = @user
    @bid.save
    respond_with(@table, @board, @bid)
  end
end
