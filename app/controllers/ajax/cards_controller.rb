class Ajax::CardsController < Ajax::BaseController
  # cache_sweeper :table_sweeper, :only => :create

  def create
    @card = @board.cards.build(params[:card])
    @card.user = @user
    @card.save
    respond_with(@table, @board, @card)
  end
end
