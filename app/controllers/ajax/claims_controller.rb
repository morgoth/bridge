class Ajax::ClaimsController < Ajax::BaseController
  def create
    @claim = @board.claims.build(params[:claim])
    @claim.user = current_user
    @claim.save
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
