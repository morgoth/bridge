module AjaxHelper
  def serialize_table
    table_structure.tap do |result|
      result["id"] = @table.id
      result["state"] = @table.state
      result["player"] = @table.user_player(current_user).direction if @table.user_player(current_user)
      serialize_info!(result["info"])
      Bridge::DIRECTIONS.each_with_index do |direction, i|
        serialize_hand!(result["hands"][i], direction)
      end
      if @board
        result["boardState"] = @board.state
        serialize_bidding_box!(result["biddingBox"]) if @board.auction?
        serialize_auction!(result["auction"])
        serialize_trick!(result["trick"]) if @board.playing?
        serialize_tricks!(result["tricks"]) if @board.playing?
        serialize_claim!(result["claim"]) if @board.playing?
        serialize_claim_preview!(result["claimPreview"]) if @board.playing? and @board.claims.active.present?
      end
    end
  end

  def serialize_info!(result)
    result.tap do |hash|
      hash["tableId"] = @table.id
      if @board
        hash["dealer"] = @board.dealer
        hash["vulnerable"] = @board.vulnerable
      end
    end
  end

  def serialize_hand!(result, direction)
    result.tap do |hash|
      hash["joinEnabled"] = join_enabled?(direction)
      hash["quitEnabled"] = quit_enabled?(direction)
      if @table.players[direction]
        hash["name"] = @table.players[direction].name
      end
      if @board
        hash["active"] = (@board.current_user.direction == direction)
        hash["cards"] = @board.visible_hands_for(@table.user_player(current_user))[direction]
        hash["cardsEnabled"] = cards_enabled?(direction)
        hash["suit"] = @board.cards.current_trick_suit
      end
    end
  end

  def serialize_bidding_box!(result)
    result.tap do |hash|
      hash["contract"] = (@board.bids.active.contracts.first and @board.bids.active.contracts.first.bid.to_s)
      if current_user_turn?
        hash["disabled"] = false
        hash["visible"] = true
        hash["doubleEnabled"] = @board.bids.double_allowed?
        hash["redoubleEnabled"] = @board.bids.redouble_allowed?
      end
    end
  end

  def serialize_auction!(result)
    result.tap do |hash|
      hash["names"] = @board.users.map(&:name)
      hash["dealer"] = @board.dealer
      hash["bids"] = @board.bids.map do |bid|
        { "bid" => bid.bid.to_s,
          "alert" => bid.user.partner == current_user ? nil : bid.alert }
      end
    end
  end

  def serialize_trick!(result)
    result.tap do |hash|
      hash["visible"] = true
      if @board.cards.current_trick.present?
        hash["lead"] = @board.deal_owner(@board.cards.current_lead.try(:card))
        hash["cards"] = @board.cards.current_trick.map { |c| c.card.to_s }
      elsif @board.cards.previous_trick.present?
        hash["lead"] = @board.deal_owner(@board.cards.previous_lead.try(:card))
        hash["cards"] = @board.cards.previous_trick.map { |c| c.card.to_s }
      end
    end
  end

  def serialize_tricks!(result)
    result.tap do |hash|
      hash["visible"] = true
      hash["contract"] = @board.contract
      hash["declarer"] = @board.declarer
      hash["resultNS"] = @board.tricks_taken("NS")
      hash["resultEW"] = @board.tricks_taken("EW")
      @board.cards.completed_tricks.each do |trick|
        hash["tricks"] << { "cards" => trick.map { |t| t.card.to_s }, "lead" => @board.deal_owner(trick.first.card.to_s), "winner" => @board.trick_winner(trick) }
      end
    end
  end

  def serialize_claim!(result)
    result.tap do |hash|
      hash["visible"] = (@board.playing_user == current_user and @board.claims.active.empty?)
      hash["maxTricks"] = 13 - @board.cards.completed_tricks_count
    end
  end

  def serialize_claim_preview!(result)
    claim = @board.claims.active.first
    result.tap do |hash|
      hash["id"] = claim.id
      hash["name"] = claim.claiming_user.name
      hash["explanation"] = claim.explanation
      hash["tricks"] = claim.tricks
      hash["total"] = claim.tricks + 0 # TODO: change later if total will be necessary
      # TODO: simplify
      hash["acceptEnabled"] = (user_signed_in? and claim.claiming_user != current_user and claim.claiming_user.partner != current_user and @board.users.dummy != current_user)
      hash["rejectEnabled"] = hash["acceptEnabled"]
      hash["cancelEnabled"] = claim.claiming_user == current_user
      hash["visible"] = true
    end
  end

  # to have always default values
  def table_structure
    { "id" => "",
      "state" => "",
      "boardState" => "",
      "player" => "",
      "hands" => [
                  { "direction" => "N", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil, "visible" => true },
                  { "direction" => "E", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil, "visible" => true },
                  { "direction" => "S", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil, "visible" => true },
                  { "direction" => "W", "name" => "", "joinEnabled" => false, "quitEnabled" => false, "cards" => [], "cardsEnabled" => false, "suit" => nil, "visible" => true }
                 ],
      "biddingBox" => {
                       "doubleEnabled" => false,
                       "redoubleEnabled" => false,
                       "contract" => nil,
                       "disabled" => true,
                       "visible" => false
                      },
      "auction" => {
                    "names" => [],
                    "dealer" => "",
                    "bids" => [],
                    "visible" => true
                   },
      "trick" => {
                  "lead" => nil,
                  "cards" => nil,
                  "visible" => false
                 },
      "tricks" => {
                   "contract" => "",
                   "declarer" => "",
                   "resultNS" => 0,
                   "resultEW" => 0,
                   "tricks" => [],
                   "visible" => false
                  },
      "info" => {
                 "tableId" => 0,
                 "vulnerable" => "NONE",
                 "dealer" => "N",
                 "visible" => true
                },
      "claim" => {
                  "maxTricks" => 13,
                  "visible" => false
                 },
      "claimPreview" => {
                         "id" => 0,
                         "name" => "",
                         "tricks" => 0,
                         "total" => 0,
                         "explanation" => "",
                         "acceptEnabled" => false,
                         "rejectEnabled" => false,
                         "cancelEnabled" => false,
                         "visible" => false
                        }
    }
  end

  def join_enabled?(direction)
    current_user.present? and @table.players[direction].blank? and @table.user_player(current_user).nil?
  end

  def quit_enabled?(direction)
    @table.players[direction].present? and current_user.present? and @table.players[direction] == @table.user_player(current_user)
  end

  def cards_enabled?(direction)
    @board.playing? and @board.playing_user == current_user and @board.cards.current_user.direction == direction
  end

  def current_user_turn?
    @board and @board.current_user == current_user
  end
end
