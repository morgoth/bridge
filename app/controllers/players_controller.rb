class PlayersController < ApplicationController
  before_filter :require_user, :fetch_table
  respond_to :json

  def create
    @player = @table.players.build(params[:player])
    respond_with(@table, @player)
  end

  def start
    @player = @table.players.find(params[:id])
    @player.start
    respond_with(@table, @player)
  end

  def reset
    @player = @table.players.find(params[:id])
    @player.reset
    respond_with(@table, @player)
  end

  private

  def fetch_table
    @table = Table.find(params[:table_id])
  end
end