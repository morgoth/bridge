module AjaxHelper
  def serialize_table(table)
    table.serializable_hash(:only => [:id, :state]).tap do |result|
      result["player"] = table.user_player(current_user).direction if table.user_player(current_user)
      result["players"] = serialize_players(table.players)
      result["board"] = serialize_board(table.boards.current) if table.boards.current
    end
  end

  def serialize_players(players)
    Bridge::DIRECTIONS.inject({}) do |hash, direction|
      hash.tap { |h| h[direction] = serialize_player(players[direction]) if players[direction] }
    end
  end

  def serialize_player(player)
    player.serializable_hash(:only => [nil], :methods => ["name"])
  end

  def serialize_board(board)
    board.serializable_hash(:only => [:state, :dealer, :declarer, :contract], :methods => ["contract_trump"]).tap do |hash|
      hash["bids"] = board.bids.map(&:bid)
      hash["hands"] = board.visible_hands_for(board.table.user_player(current_user))
    end
  end
end
