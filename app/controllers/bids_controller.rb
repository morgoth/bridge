class BidsController < ApplicationController
  before_filter :require_user, :fetch_table, :fetch_board
  respond_to :json

  def create
    @bid = @board.bids.build(params[:bid])
    respond_with(@table, @board, @bid)
  end

  private

  def fetch_table
    @table = Table.find(params[:table_id])
  end

  def fetch_board
    @board = @table.boards.find(params[:board_id])
  end
end
