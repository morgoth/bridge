class Ajax::CardsController < Ajax::ApplicationController
  def create
    @card = @board.cards.build(params[:card])
    @card.user = @user
    @card.save
    respond_with(@table, @board, @card)
  end
end
