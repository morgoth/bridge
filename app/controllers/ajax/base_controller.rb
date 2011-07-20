class Ajax::BaseController < ApplicationController
  before_filter :fetch_table, :fetch_board

  respond_to :json

  # self.responder = AjaxResponder

  protected

  def fetch_table
    @table = Table.find(params[:table_id])
  end

  def fetch_board
    @board = @table.boards.current
  end
end
