class Ajax::BaseController < ApplicationController
  before_filter :fetch_table, :fetch_board, :fetch_user

  respond_to :json

  self.responder = AjaxResponder

  protected

  def fetch_table
    logger.info "fetch_table"
    @table = Table.find(params[:table_id])
  end

  def fetch_board
    logger.info "fetch_board"
    @board = @table.boards.current
  end

  def fetch_user
    logger.info "fetch_user"
    @user = current_user
  end
end
