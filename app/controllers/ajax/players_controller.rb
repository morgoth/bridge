class Ajax::PlayersController < Ajax::BaseController
  before_filter :fetch_player, :except => [:create]

  def create
    @player = @table.players.create(params[:player])
    respond_with(@table, @player)
  end

  def destroy
    @player.destroy
    respond_with(@table, @player)
  end

  def start
    @player.start
    respond_with(@table, @player)
  end

  def reset
    @player.reset
    respond_with(@table, @player)
  end

  protected

  def fetch_player
    @player = @table.players.find_by_user_id(current_user.try(:id))
  end
end
