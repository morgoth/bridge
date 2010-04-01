module AjaxHelper
  def serialize_table(table)
    table_structure.tap do |result|
      result["id"] = table.id
      result["state"] = table.state
      result["player"] = table.user_player(current_user).direction if table.user_player(current_user)
      Bridge::DIRECTIONS.each_with_index do |direction, i|
        serialize_hand!(result["hands"][i], table, direction)
      end
      if board = table.boards.current
        result["boardState"] = board.state if board.auction? and table.user_player(current_user)
        serialize_bidding_box!(result["biddingBox"], board) if board.auction?
        serialize_auction!(result["auction"], board)
        serialize_trick!(result["trick"], board) if board.playing?
        serialize_tricks!(result["tricks"], board) if board.playing?
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
      if board = table.boards.current
        hash["cards"] = board.visible_hands_for(table.user_player(current_user))[direction]
        hash["cardsEnabled"] = cards_enabled?(board, direction)
        hash["suit"] = board.cards.current_trick_suit
      end
    end
  end

  def serialize_bidding_box!(result, board)
    result.tap do |hash|
      hash["contract"] = (board.bids.active.contracts.first and board.bids.active.contracts.first.bid.to_s)
      if current_user_turn?(board)
        hash["disabled"] = false
        hash["doubleEnabled"] = board.bids.double_allowed?
        hash["redoubleEnabled"] = board.bids.redouble_allowed?
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
      if board.cards.current_trick.present?
        hash["lead"] = board.deal_owner(board.cards.current_lead.try(:card))
        hash["cards"] = board.cards.current_trick.map { |c| c.card.to_s }
      elsif board.cards.previous_trick.present?
        hash["lead"] = board.deal_owner(board.cards.previous_lead.try(:card))
        hash["cards"] = board.cards.previous_trick.map { |c| c.card.to_s }
      end
    end
  end

  def serialize_tricks!(result, board)
    result.tap do |hash|
      hash["contract"] = board.contract
      hash["declarer"] = board.declarer
      hash["resultNS"] = board.tricks_taken("NS")
      hash["resultEW"] = board.tricks_taken("EW")
      board.cards.completed_tricks.each do |trick|
        hash["tricks"] << { "cards" => trick.map { |t| t.card.to_s }, "lead" => board.deal_owner(trick.first.card.to_s), "winner" => board.trick_winner(trick) }
      end
    end
  end

  # to have always default values
  def table_structure
    { "id" => "",
      "state" => "",
      "boardState" => "",
      "player" => "",
      "hands" => [
                  { "direction" => "N", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                  { "direction" => "E", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                  { "direction" => "S", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil },
                  { "direction" => "W", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil }
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
                 },
      "tricks" => {
                   "contract" => "",
                   "declarer" => "",
                   "resultNS" => 0,
                   "resultEW" => 0,
                   "tricks" => []
                  }
    }
  end

  def join_enabled?(table, direction)
    current_user.present? and table.players[direction].blank? and table.user_player(current_user).nil?
  end

  def quit_enabled?(table, direction)
    table.players[direction].present? and current_user.present? and table.players[direction] == table.user_player(current_user)
  end

  # TODO: do some refactoring
  def cards_enabled?(board, direction)
    if board.playing?
      (quit_enabled?(board.table, direction) and current_user_turn?(board) and board.users.dummy != current_user) ||
      (current_user.present? and board.current_user.dummy? and board.users[direction] == board.users.dummy and board.users.declarer == current_user)
    else
      false
    end
  end

  def current_user_turn?(board)
    board and board.current_user == current_user
  end
end
