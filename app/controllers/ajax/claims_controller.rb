class Ajax::ClaimsController < Ajax::BaseController
  def create
    @claim = @board.claims.create(params[:claim])
    respond_with(@table, @board, @claim)
  end

  def accept
    @claim = @board.claims.find(params[:id])
    @claim.user = current_user
    @claim.accept
    respond_with(@table, @board, @claim)
  end

  def reject
    @claim = @board.claims.find(params[:id])
    @claim.user = current_user
    @claim.reject
    respond_with(@table, @board, @claim)
  end
end
