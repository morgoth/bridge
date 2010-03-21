module AjaxHelper
  def serialize_table(table)
    table_structure.tap do |result|
      result["id"] = table.id
      result["state"] = table.state
      result["player"] = table.user_player(current_user).direction if table.user_player(current_user)
      Bridge::DIRECTIONS.each_with_index do |direction, i|
        serialize_hand!(result["hands"][i], table, direction)
      end
      serialize_bidding_box!(result["biddingBox"], table.boards.current) if table.boards.current and table.boards.current.auction? and table.user_player(current_user)
      serialize_auction!(result["auction"], table.boards.current) if table.boards.current
      serialize_trick!(result["trick"], table.boards.current) if table.boards.current and table.boards.current.playing?
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
        hash["suit"] = table.boards.current.cards.current_trick_suit
      end
    end
  end

  def serialize_bidding_box!(result, board)
    result.tap do |hash|
      hash["contract"] = (board.bids.active.contracts.first and board.bids.active.contracts.first.bid.to_s)
      if current_user_turn?(board)
        hash["disabled"] = false
        # FIXME: don't build objects
        hash["doubleEnabled"] = board.bids.new(:user => current_user, :bid => "X").valid?
        hash["redoubleEnabled"] = board.bids.new(:user => current_user, :bid => "XX").valid?
      end
    end
  end

  def serialize_auction!(result, board)
    result.tap do |hash|
      hash["names"] = board.users.map(&:name)
      hash["dealer"] = board.dealer
      hash["bids"] = board.bids.map { |b| { "bid" => b.bid.to_s, "alert" => b.alert } }
    end
  end

  def serialize_trick!(result, board)
    result.tap do |hash|
      hash["lead"] = board.deal_owner(board.cards.current_lead.try(:card))
      hash["cards"] = (board.cards.current_trick.present? and board.cards.current_trick.map { |c| c.card.to_s })
    end
  end

  # to have always default values
  def table_structure
    { "id" => "",
      "state" => "",
      "player" =>"",
      "hands" => [
                  { "direction" => "N", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                  { "direction" => "E", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                  { "direction" => "S", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                  { "direction" => "W", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                 ],
      "biddingBox" => {
                       "doubleEnabled" => false,
                       "redoubleEnabled" => false,
                       "contract" => nil,
                       "disabled" => true
                      },
      "auction" => {
                    "names" => [],
                    "dealer" => "",
                    "bids" => []
                   },
      "trick" => {
                  "lead" => nil,
                  "cards" => nil
                 }
    }
  end

  def join_enabled?(table, direction)
    table.players[direction].blank? and current_user.present?
  end

  def quit_enabled?(table, direction)
    table.players[direction].present? and current_user.present? and table.players[direction] == table.user_player(current_user)
  end

  def cards_enabled?(table, direction)
    quit_enabled?(table, direction) and table.boards.current.playing? and current_user_turn?(table.boards.current)
  end

  def current_user_turn?(board)
    board and board.current_user == current_user
  end
end
