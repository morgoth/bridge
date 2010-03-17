class Board < ActiveRecord::Base
  acts_as_list :scope => :table

  %w(n e s w).each { |d| belongs_to "user_#{d}", :class_name => "User", :extend => UserBoardExtension }
  has_many :bids, :order => "bids.position", :extend => BidsBoardExtension
  has_many :cards, :order => "cards.position", :extend => CardsBoardExtension
  has_many :claims

  delegate :n, :e, :s, :w, :owner, :to => :deal, :prefix => true, :allow_nil => true

  def deal
    Bridge::Deal.from_id(deal_id.to_i)
  rescue ArgumentError
  end

  def dealer_number
    Bridge::DIRECTIONS.index(dealer)
  end

  def contract_trump
    contract_without_modifier && contract_without_modifier.trump
  end

  def contract_suit
    contract_without_modifier && contract_without_modifier.suit
  end

  def contract_without_modifier
    contract && Bridge::Bid.new(contract.gsub("X", ""))
  end

  def cards_left(direction = nil)
    users_cards = cards.inject(deal.to_hash) do |current_cards, card|
      current_cards[card.user.direction].delete(card.to_s)
      current_cards = current_cards
    end
    direction.nil? ? users_cards : users_cards[direction]
  end

  def card_owner(card)
    direction = deal_owner(card)
    users[direction]
  end

  # TODO: test
  def declarer_user
    users[declarer]
  end

  # TODO: test
  def first_lead_user
    declarer_user.next
  end

  # TODO: test
  def dummy_user
    first_lead_user.next
  end

  def users
    [user_n, user_e, user_s, user_w].extend(UsersBoardExtension)
  end

  def users=(users)
    user_n, user_e, user_s, user_w = users
  end

  def tricks_taken(side = nil)
    hash = cards.tricks.inject(Hash.new(0)) do |h, trick|
      card = Bridge::Trick.new(trick.map(&:card)).winner(contract_trump)
      direction = deal_owner(card)
      h[direction] += 1
      h
    end
    side.nil? ? hash : side.to_s.upcase.split("").inject(0) { |sum, direction| sum += hash[direction] }
  end

  def declarer_vulnerable?
    case vulnerable
    when "BOTH"
     true
    when "NONE"
     false
    else
      vulnerable.split('').include?(declarer)
    end
  end

  def tricks_ew
    13 - tricks_ns
  end

  def for_ajax(player)
    serializable_hash(:only => [:state, :dealer, :declarer, :contract], :methods => ["contract_trump"]).tap do |hash|
      hash["bids"] = bids.map(&:bid)
      hash["hands"] = hands_for(player)
    end
  end

  scope :auction, where(:state => "auction")
  scope :playing, where(:state => "playing")
  scope :completed, where(:state => "completed")

  state_machine :initial => :auction do
    event :bid_made do
      transition :auction => :completed, :if => :four_passes?
      transition :auction => :playing, :if => :end_of_auction?
    end

    event :card_played do
      transition :playing => :completed, :if => :end_of_play?
    end

    event :claimed do
      transition :playing => :completed, :if => :claim_accepted?
    end

    before_transition :auction => :playing, :do => [:set_contract, :set_declarer]
    before_transition :playing => :completed, :do => [:set_tricks, :set_points]
  end

  private

  def four_passes?
    bids.count == 4 && bids.where(:bid => Bridge::PASS).count == 4
  end

  def end_of_auction?
    bids.count > 3 && bids.order("position DESC").limit(3).all?(&:pass?)
  end

  def end_of_play?
    cards.count == 52
  end

  def claim_accepted?
    claims.accepted.exists?
  end

  def set_contract
    self.contract = bids.final.last.bid.to_s.tap do |c|
      c << bids.active.modifiers.last.bid.to_s if bids.active.modifiers.present?
    end
  end

  def set_declarer
    self.declarer = bids.final.first.user.direction
  end

  def set_tricks
    if claim_accepted?
      claim_tricks = claims.accepted.last.tricks
      claim_direction = claims.accepted.last.claiming_user.direction
      taken_ns = claim_tricks if ["N", "S"].include?(claim_direction)
    end
    taken_ns ||= 0
    taken_ns += tricks_taken("NS")
    self.tricks_ns = taken_ns
  end

  def set_points
    score = Bridge::Score.new(:contract => contract, :vulnerable => declarer_vulnerable?, :tricks => send("tricks_#{Bridge.side_of(declarer).downcase}"))
    self.points_ns = ["N", "S"].include?(declarer) ? score.points : -score.points
  end

  def hands_for(player)
    cards_left.tap do |left|
      directions = left.keys
      directions.delete(player.direction)
      directions.delete(dummy_user.direction) if cards.count > 0
      directions.delete(claims.active.last.claiming_user.direction) if claims.active.present?
      directions.each { |d| left[d] = left[d].map { "" } }
    end
  end
end
