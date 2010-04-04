class Ajax::PlayersController < Ajax::BaseController
  cache_sweeper :table_sweeper
  before_filter :fetch_player, :except => [:create]

  def create
    @player = @table.players.build(params[:player])
    @player.user = current_user
    @player.save
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
