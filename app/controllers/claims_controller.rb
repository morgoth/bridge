class ClaimsController < ApplicationController
  before_filter :require_user, :fetch_table, :fetch_board
  respond_to :json

  def create
    @claim = @board.claims.build(params[:claim])
    respond_with(@table, @board, @claim)
  end

  def accept
    @claim = @board.claims.find(params[:id])
    @claim.user = @current_user
    @claim.accept
    respond_with(@table, @board, @claim)
  end

  def reject
    @claim = @board.claims.find(params[:id])
    @claim.user = @current_user
    @claim.reject
    respond_with(@table, @board, @claim)
  end

  private

  def fetch_table
    @table = Table.find(params[:table_id])
  end

  def fetch_board
    @board = @table.boards.find(params[:board_id])
  end
end