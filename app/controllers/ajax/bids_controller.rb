class Ajax::BidsController < Ajax::ApplicationController
  def create
    @bid = @board.bids.build(params[:bid])
    @bid.user = @user
    @bid.save
    respond_with(@table, @board, @bid)
  end
end
