module AjaxHelper
  def serialize_table(table, user)
    table_structure.tap do |result|
      result["tableId"] = table.id
      result["tableVersion"] = table.version
      result["state"] = table.state
      result["player"] = table.user_player(user).direction if table.user_player(user)
      result["channelName"] = channel_name(table, user)
      serialize_info!(table, user, result["info"])
      Bridge::DIRECTIONS.each_with_index do |direction, i|
        serialize_hand!(table, user, result["hands"][i], direction)
      end
      if table.boards.current
        result["boardState"] = table.boards.current.state
        serialize_bidding_box!(table, user, result["biddingBox"]) if table.boards.current.auction?
        serialize_auction!(table, user, result["auction"])
        serialize_trick!(table, user, result["trick"]) if table.boards.current.playing?
        serialize_tricks!(table, user, result["tricks"]) if table.boards.current.playing?
        serialize_claim!(table, user, result["claim"]) if table.boards.current.playing?
        serialize_claim_preview!(table, user, result["claimPreview"]) if table.boards.current.playing? and table.boards.current.claims.active.present?
      end
    end
  end

  def serialize_info!(table, user, result)
    result.tap do |hash|
      hash["tableId"] = table.id
      if table.boards.current
        hash["dealer"] = table.boards.current.dealer
        hash["vulnerable"] = table.boards.current.vulnerable
      end
    end
  end

  def serialize_hand!(table, user, result, direction)
    result.tap do |hash|
      hash["joinEnabled"] = join_enabled?(table, user, direction)
      hash["quitEnabled"] = quit_enabled?(table, user, direction)
      if table.players[direction]
        hash["name"] = table.players[direction].name
      end
      if table.boards.current
        hash["active"] = (table.boards.current.current_user.direction == direction)
        hash["cards"] = table.boards.current.visible_hands_for(table.user_player(user).try(:direction))[direction]
        hash["cardsEnabled"] = cards_enabled?(table, user, direction)
        hash["suit"] = table.boards.current.cards.current_trick_suit
      end
    end
  end

  def serialize_bidding_box!(table, user, result)
    result.tap do |hash|
      hash["contract"] = (table.boards.current.bids.active.contracts.first and table.boards.current.bids.active.contracts.first.bid.to_s)
      if current_user_turn?(table, user)
        hash["disabled"] = false
        hash["visible"] = true
        hash["doubleEnabled"] = table.boards.current.bids.double_allowed?
        hash["redoubleEnabled"] = table.boards.current.bids.redouble_allowed?
      end
    end
  end

  def serialize_auction!(table, user, result)
    result.tap do |hash|
      hash["names"] = table.boards.current.users.map(&:name)
      hash["dealer"] = table.boards.current.dealer
      hash["vulnerable"] = table.boards.current.vulnerable
      hash["bids"] = table.boards.current.bids.map do |bid|
        { "bid" => bid.bid.to_s,
          "alert" => bid.user.partner == user ? nil : bid.alert }
      end
    end
  end

  def serialize_trick!(table, user, result)
    result.tap do |hash|
      hash["visible"] = true
      if table.boards.current.cards.current_trick.present?
        hash["lead"] = table.boards.current.deal_owner(table.boards.current.cards.current_lead.try(:card))
        hash["cards"] = table.boards.current.cards.current_trick.map { |c| c.card.to_s }
      elsif table.boards.current.cards.previous_trick.present?
        hash["lead"] = table.boards.current.deal_owner(table.boards.current.cards.previous_lead.try(:card))
        hash["cards"] = table.boards.current.cards.previous_trick.map { |c| c.card.to_s }
      end
    end
  end

  def serialize_tricks!(table, user, result)
    result.tap do |hash|
      hash["visible"] = true
      hash["contract"] = table.boards.current.contract
      hash["declarer"] = table.boards.current.declarer
      hash["resultNS"] = table.boards.current.tricks_taken("NS")
      hash["resultEW"] = table.boards.current.tricks_taken("EW")
      table.boards.current.cards.completed_tricks.each do |trick|
        hash["tricks"] << { "cards" => trick.map { |t| t.card.to_s }, "lead" => table.boards.current.deal_owner(trick.first.card.to_s), "winner" => table.boards.current.trick_winner(trick) }
      end
    end
  end

  def serialize_claim!(table, user, result)
    result.tap do |hash|
      hash["visible"] = (table.boards.current.playing_user == user and table.boards.current.claims.active.empty?)
      hash["maxTricks"] = 13 - table.boards.current.cards.completed_tricks_count
    end
  end

  def serialize_claim_preview!(table, user, result)
    claim = table.boards.current.claims.active.first
    result.tap do |hash|
      hash["claimId"] = claim.id
      hash["name"] = claim.claiming_user.name
      hash["explanation"] = claim.explanation
      hash["tricks"] = claim.tricks
      # FIXME: total should indicate total number of tricks to take by declarer
      hash["total"] = claim.tricks + 0 # TODO: change later if total will be necessary
      hash["acceptEnabled"] = claim.accept_users.include?(user)
      hash["rejectEnabled"] = claim.reject_users.include?(user)
      hash["cancelEnabled"] = (claim.claiming_user == user)
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
                    "vulnerable" => "NONE",
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

  def join_enabled?(table, user, direction)
    user.present? and table.players[direction].blank? and table.user_player(user).nil?
  end

  def quit_enabled?(table, user, direction)
    table.players[direction].present? and user.present? and table.players[direction] == table.user_player(user)
  end

  def cards_enabled?(table, user, direction)
    table.boards.current.playing? and table.boards.current.playing_user == user and table.boards.current.cards.current_user.direction == direction
  end

  def current_user_turn?(table, user)
    table.boards.current and table.boards.current.current_user == user
  end
end
