class Ajax::BidsController < Ajax::BaseController
  def create
    @bid = @board.bids.create(params[:bid])
    respond_with(@table, @board, @bid)
  end
end
