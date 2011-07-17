class Board < ActiveRecord::Base
  include Board::States

  acts_as_list :scope => :table

  %w[n e s w].each { |d| belongs_to "user_#{d}", :class_name => "User" }
  has_many :bids, :order => "bids.position", :extend => BidsBoardExtension
  has_many :cards, :order => "cards.position", :extend => CardsBoardExtension
  has_many :claims
  belongs_to :table, :touch => true

  validates :deal_id, :presence => true
  validates :dealer, :presence => true, :inclusion => Bridge::DIRECTIONS
  validates :vulnerable, :presence => true, :inclusion => Bridge::VULNERABILITIES

  scope :auction, where(:state => "auction")
  scope :playing, where(:state => "playing")
  scope :completed, where(:state => "completed")

  delegate :n, :e, :s, :w, :owner, :cards_for, :hcp, :to => :deal, :prefix => true, :allow_nil => true
  delegate :create_board!, :to => :table, :prefix => true, :allow_nil => true

  %w[n e s w].each do |d|
    define_method("user_#{d}_with_direction") do
      user_n_without_direction.tap do |user|
        user && user.define_singleton_method(:direction) { d.upcase }
      end
    end
    alias_method_chain "user_#{d}", :direction
  end

  def deal
    Bridge::Deal.from_id(deal_id.to_i)
  rescue ArgumentError
  end

  def dealer_number
    Bridge::DIRECTIONS.index(dealer)
  end

  def contract_trump
    contract_without_modifier.try(:trump)
  end

  def contract_suit
    contract_without_modifier.try(:suit)
  end

  def contract_without_modifier
    contract && Bridge::Bid.new(contract.gsub("X", ""))
  end

  def cards_left
    played_cards = cards.map(&:to_s)

    {}.tap do |h|
      deal.sort_by_color!(contract_trump).to_hash.each { |direction, cards| h[direction] = cards - played_cards }
    end
  end

  def current_user
    return bids.current_user if auction?
    return cards.current_user if playing?
  end

  def playing_user
    return bids.current_user if auction?
    return cards.playing_user if playing?
  end

  def users
    Proxies::Proxy.new(lambda { [user_n, user_e, user_s, user_w] }, :owner => self, :extend => UsersBoardExtension)
  end

  def users=(users)
    user_n, user_e, user_s, user_w = users
  end

  def tricks_taken(side = nil)
    hash = cards.completed_tricks.inject(Hash.new(0)) do |taken, trick|
      direction = trick_winner(trick)
      taken[direction] += 1
      taken
    end
    side.nil? ? hash : side.to_s.upcase.split("").inject(0) { |sum, direction| sum += hash[direction] }
  end

  def trick_winner(trick)
    card = Bridge::Trick.new(trick.map(&:card)).winner(contract_trump)
    deal_owner(card)
  end

  def declarer_vulnerable?
    direction_vulnerable?(declarer)
  end

  def direction_vulnerable?(direction)
    case vulnerable
    when "BOTH"
     true
    when "NONE"
     false
    else
      vulnerable.split('').include?(direction)
    end
  end

  def tricks_ew
    tricks_ns.present? ? 13 - tricks_ns : nil
  end

  def visible_hands_for(player_or_direction)
    direction = player_or_direction.respond_to?(:direction) ? player_or_direction.direction : player_or_direction

    visible_directions = [direction]
    visible_directions << users.dummy.direction if cards.count > 0
    visible_directions << claims.active.last.claiming_user.direction if claims.active.present?
    visible_directions.uniq!

    cards_left.tap do |left|
      (Bridge::DIRECTIONS - visible_directions).each { |d| left[d].fill("") }
    end
  end

  def score
    if completed? or (tricks_ns.present? and contract.present? and declarer.present?)
      @score ||= Bridge::Score.new(:contract => contract, :vulnerable => declarer_vulnerable?, :tricks => send("tricks_#{Bridge.side_of(declarer).downcase}"))
    end
  end

  def chicago_imp_ns
    if completed?
      hcp_ns = deal_hcp("NS")
      if hcp_ns >= 20
        Bridge::Points::Chicago.new(:hcp => hcp_ns, :vulnerable => direction_vulnerable?("N"), :points => points_ns).imps
      else
        -Bridge::Points::Chicago.new(:hcp => 40 - hcp_ns, :vulnerable => direction_vulnerable?("E"), :points => -points_ns).imps
      end
    end
  end

  private

  def four_passes?
    bids.count == 4 && bids.where(:bid => Bridge::PASS).count == 4
  end

  def end_of_auction?
    bids.count > 3 && bids.last(3).all?(&:pass?)
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
    self.points_ns = ["N", "S"].include?(declarer) ? score.points : - score.points
  end
end
