class Serializer
  include ChannelHelper
  extend ActiveSupport::Memoizable

  attr_reader :table, :board

  def initialize(table)
    @table = table
    @board = @table.boards.current
  end

  def config(user)
    {:id => table.id, :state => table.state, :tableVersion => table.version, :boardState => ""}.tap do |config|
      config[:player] = table.players.for(user).try(:direction)
      config[:boardState] = board.state if board?
      config[:channelName] = channel_name(table, user)
      config[:info] = info
      config[:auction] = auction(user)
      config[:biddingBox] = bidding_box(user)
      config[:trick] = trick
      config[:tricks] = tricks
      config[:claim] = claim(user)
      config[:claimPreview] = claim_preview(user)
      config[:hands] = Bridge::DIRECTIONS.map { |d| hand(user, d) }
      config[:bar] = bar(user)
    end
  end

  def info
    Rails.cache.fetch("serializer/info/table-#{table_id}/board-#{board_id}") do
      {:tableId => table.id, :dealer => "", :vulnerable => "", :visible => true}.tap do |info|
        if board?
          info[:dealer] = board.dealer
          info[:vulnerable] = board.vulnerable
        end
      end
    end
  end
  memoize :info

  def auction(user)
    Rails.cache.fetch("serializer/auction/table-#{table_id}/board-#{board_id}/bids-#{board_bids_count}/user-#{user.try(:id)}") do
      {:names => [], :dealer => "", :vulnerable => "", :visible => true, :bids => []}.tap do |auction|
        if board?
          auction[:names] = board.users.map(&:name)
          auction[:dealer] = board.dealer
          auction[:vulnerable] = board.vulnerable
          auction[:bids] = board.bids.map do |bid|
            {:bid => bid.bid.to_s, :alert => bid.user.partner == user ? nil : bid.alert}
          end
        end
      end
    end
  end

  def bidding_box(user)
    {:contract => "", :disabled => true, :visible => false, :doubleEnabled => false, :redoubleEnabled => false}.tap do |bidding_box|
      if auction?
        bidding_box[:contract] = active_contract
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
    Rails.cache.fetch("serializer/trick/table-#{table_id}/board-#{board_id}/cards-#{board_cards_count}") do
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
  end
  memoize :trick

  def tricks
    Rails.cache.fetch("serializer/tricks/table-#{table_id}/board-#{board_id}/state-#{board_state}/tricks-#{board_tricks_count}") do
      {:contract => "", :declarer => "", :resultNS => 0, :resultEW => 0, :tricks => [], :visible => false}.tap do |tricks|
        if playing?
          tricks[:visible] = true
          tricks[:contract] = board.contract
          tricks[:declarer] = board.declarer
          tricks[:resultNS] = board.tricks_taken("NS")
          tricks[:resultEW] = board.tricks_taken("EW")
          tricks[:tricks] = board.cards.completed_tricks.map do |trick|
            {:cards => trick.map { |t| t.card.to_s }, :lead => board.deal_owner(trick.first.card.to_s), :winner => board.trick_winner(trick)}
          end
        end
      end
    end
  end
  memoize :tricks

  # TODO: check if we need attribute 'visible'
  def claim(user)
    {:maxTricks => 13, :visible => false}.tap do |claim|
      if playing?
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
        claim_preview[:total] = claim.declarer_total_tricks
        claim_preview[:acceptEnabled] = claim.accept_users.include?(user)
        claim_preview[:rejectEnabled] = claim.reject_users.include?(user)
        claim_preview[:cancelEnabled] = (claim.claiming_user == user)
        claim_preview[:visible] = true
      end
    end
  end

  def hand(user, direction)
    {:direction => direction, :name => "", :joinEnabled => false, :cards => [], :cardsEnabled => false, :suit => nil, :visible => true, :active => false, :suit => "", :cardsEnabled => false}.tap do |hand|
      hand[:joinEnabled] = join_enabled?(user, direction)
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

  def bar(user)
    {:visible => true, :quitEnabled => false, :claimEnabled => false}.tap do |hand|
      hand[:quitEnabled] = quit_enabled?(user)
      hand[:claimEnabled] = (playing? and board.playing_user == user and board.claims.active.empty?)
    end
  end

  private

  def user_turn?(user)
    board? and board.current_user == user
  end
  memoize :user_turn?

  def board?
    board.present?
  end
  memoize :board?

  def auction?
    board? and board.auction?
  end
  memoize :auction?

  def playing?
    board? and board.playing?
  end
  memoize :playing?

  def claim?
    playing? and board.claims.active.present?
  end
  memoize :claim?

  def join_enabled?(user, direction)
    table.players[direction].blank? and table.players.for(user).nil?
  end
  memoize :join_enabled?

  def quit_enabled?(user)
    user.present? and table.players.for(user).present?
  end
  memoize :quit_enabled?

  def cards_enabled?(user, direction)
    playing? and board.playing_user == user and board.cards.current_user.direction == direction
  end
  memoize :cards_enabled?

  def table_id
    table.id
  end
  memoize :table_id

  def board_id
    board.try(:id)
  end
  memoize :board_id

  def board_state
    board.try(:state)
  end
  memoize :board_state

  def board_bids_count
    board.try(:bids).try(:count)
  end
  memoize :board_bids_count

  def active_contract
    board.bids.active.contracts.first and board.bids.active.contracts.first.bid.to_s
  end
  memoize :active_contract

  def board_cards_count
    board.try(:cards).try(:count)
  end

  def board_tricks_count
    board_cards_count && board_cards_count.div(4)
  end
end
