module AjaxHelper
  def serialize_table(table)
    table_structure.tap do |result|
      result["id"] = table.id
      result["state"] = table.state
      result["player"] = table.user_player(current_user).direction if table.user_player(current_user)
      Bridge::DIRECTIONS.each_with_index do |direction, i|
        serialize_hand!(result["hands"][i], table, direction)
      end
    end
  end

  def serialize_hand!(result, table, direction)
    result.tap do |hash|
      hash["joinEnabled"] = join_enabled?(table, direction)
      hash["quitEnabled"] = quit_enabled?(table, direction)
      if table.players[direction]
        hash["name"] = table.players[direction].name
      end
      if table.boards.current
        hash["cards"] = table.boards.current.visible_hands_for(table.user_player(current_user))[direction]
        hash["cardsEnabled"] = cards_enabled?(table, direction)
      end
    end
  end

  # to have always default values
  def table_structure
    { "id" => "",
      "state" => "",
      "player" =>"",
      "hands" => [
                  { "direction" => "N", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false },
                  { "direction" => "E", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false },
                  { "direction" => "S", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false },
                  { "direction" => "W", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false }
                 ]
    }
  end

  def join_enabled?(table, direction)
    table.players[direction].blank? and current_user.present?
  end

  def quit_enabled?(table, direction)
    table.players[direction].present? and current_user.present? and table.players[direction] == table.user_player(current_user)
  end

  def cards_enabled?(table, direction)
    quit_enabled?(table, direction) and table.boards.current.playing? and current_user == table.boards.current.current_user
  end
end
