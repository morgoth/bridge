class Serializer
  attr_reader :table, :board

  def config(user)
    {:id => table.id, :state => table.state, :tableVersion => table.version, :boardState => ""}.tap do |config|
      config[:player] = table.players.for(user).try(:direction)
      config[:boardState] = board.state if board?
      config[:channelName] = channel_name(user)
      config[:info] = info
      config[:auction] = auction(user)
      config[:bidding_box] = bidding_box(user)
      config[:trick] = trick
      config[:tricks] = tricks
      config[:claim] = claim(user)
      config[:claimPreview] = claim_preview(user)
      config[:hands] = Bridge::DIRECTIONS.inject([]) do |hands, direction|
        hands << hand(user, direction)
      end
    end
  end

  def info
    {:tableId => table.id, :dealer => "", :vulnerable => "", :visible => true}.tap do |info|
      if board?
        info[:dealer] = board.dealer
        info[:vulnerable] = board.vulnerable
      end
    end
  end

  def auction(user)
    {:names => [], :dealer => "", :vulnerable => "", :visible => true, :bids => []}.tap do |auction|
      if board?
        auction[:names] = board.users.map(&:name)
        auction[:dealer] = board.dealer
        auction[:vulnerable] = board.vulnerable
        auction[:bids] = board.bids.map do |bid|
          {:bid => bid.bid.to_s,
           :alert => bid.user.partner == user ? nil : bid.alert}
        end
      end
    end
  end

  def bidding_box(user)
    {:contract => "", :disabled => true, :visible => false, :doubleEnabled => false, :redoubleEnabled => false}.tap do |bidding_box|
      if auction?
        bidding_box[:contract] = (board.bids.active.contracts.first and board.bids.active.contracts.first.bid.to_s) # cache in instance variable probably
        if user_turn?(user)
          bidding_box[:disabled] = false
          bidding_box[:visible] = true
          bidding_box[:doubleEnabled] = board.bids.double_allowed?
          bidding_box[:redoubleEnabled] = board.bids.redouble_allowed?
        end
      end
    end
  end

  def trick
    {:lead => nil, :cards => nil, :visible => false}.tap do |trick|
      if playing?
        trick[:visible] = true
        if board.cards.current_trick.present?
          trick[:lead] = board.deal_owner(board.cards.current_lead.try(:card))
          trick[:cards] = board.cards.current_trick.map { |c| c.card.to_s }
        elsif board.cards.previous_trick.present?
          trick[:lead] = board.deal_owner(board.cards.previous_lead.try(:card))
          trick[:cards] = board.cards.previous_trick.map { |c| c.card.to_s }
        end
      end
    end
  end

  def tricks
    {:contract => "", :declarer => "", :resultNS => 0, :resultEW => 0, :tricks => [], :visible => false}.tap do |tricks|
      if playing?
        tricks[:visible] = true
        tricks[:contract] = board.contract
        tricks[:declarer] = board.declarer
        tricks[:resultNS] = board.tricks_taken("NS")
        tricks[:resultEW] = board.tricks_taken("EW")
        board.cards.completed_tricks.each do |trick|
          tricks[:tricks] << {:cards => trick.map { |t| t.card.to_s }, :lead => board.deal_owner(trick.first.card.to_s), :winner => board.trick_winner(trick)}
        end
      end
    end
  end

  def claim(user)
    {:maxTricks => 13, :visible => false}.tap do |claim|
      if playing?
        claim[:visible] = (board.playing_user == user and board.claims.active.empty?)
        claim[:maxTricks] = 13 - board.cards.completed_tricks_count
      end
    end
  end

  def claim_preview(user)
    {:claimId => 0, :name => "", :tricks => 0, :total => 0, :explanation => "", :acceptEnabled => false, :rejectEnabled => false, :cancelEnabled => false, :visible => false}.tap do |claim_preview|
      if claim?
        claim = board.claims.active.first
        claim_preview[:claimId] = claim.id
        claim_preview[:name] = claim.claiming_user.name
        claim_preview[:explanation] = claim.explanation
        claim_preview[:tricks] = claim.tricks
        # FIXME: total should indicate total number of tricks to take by declarer
        claim_preview[:total] = claim.tricks + 0
        claim_preview[:acceptEnabled] = claim.accept_users.include?(user)
        claim_preview[:rejectEnabled] = claim.reject_users.include?(user)
        claim_preview[:cancelEnabled] = (claim.claiming_user == user)
        claim_preview[:visible] = true
      end
    end
  end

  def hand(user, direction)
    {:direction => direction, :name => "", :joinEnabled => false, :quitEnabled => false, :cards => [], :cardsEnabled => false, :suit => nil, :visible => true, :active => false, :suit => "", :cardsEnabled => false}.tap do |hand|
      hand[:joinEnabled] = join_enabled?(user, direction)
      hand[:quitEnabled] = quit_enabled?(user, direction)
      if player = table.players[direction]
        hand[:name] = player.name
      end
      if board?
        hand[:active] = (board.current_user.direction == direction)
        hand[:cards] = board.visible_hands_for(table.players.for(user))[direction]
        hand[:cardsEnabled] = cards_enabled?(user, direction)
        hand[:suit] = board.cards.current_trick_suit
      end
    end
  end

  private

  def user_turn?(user)
    board? and board.current_user == user
  end

  def initialize(table)
    @table = table
    @board = @table.boards.current
  end

  def board?
    board.present?
  end

  def auction?
    board? and board.auction?
  end

  def playing?
    board? and board.playing?
  end

  def claim?
    playing? and board.claims.active.present?
  end

  def join_enabled?(user, direction)
    user.present? and table.players[direction].blank? and table.players.for(user).nil?
  end

  def quit_enabled?(user, direction)
    table.players[direction].present? and user.present? and table.players[direction] == table.players.for(user)
  end

  def cards_enabled?(user, direction)
    playing? and board.playing_user == user and board.cards.current_user.direction == direction
  end

  # FIXME: do not duplicate code (same in application controller)
  def channel_name(user)
    "table-#{table.id}".tap { |name| name.replace("private-#{name}-user-#{user.id}") if user && table.players.for(user) }
  end
end