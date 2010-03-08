class Ajax::CardsController < Ajax::BaseController
  def create
    @card = @board.cards.create(params[:card])
    respond_with(@table, @board, @card)
  end
end
