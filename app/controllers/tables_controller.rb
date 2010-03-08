class TablesController < ApplicationController
  before_filter :require_user
  respond_to :html, :json

  def create
    @table = Table.new(params[:table])
    respond_with(@table)
  end

  def show
    @table = Table.find(params[:id])
    @board = @table.boards.last
  end
end