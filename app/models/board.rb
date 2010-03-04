class Board < ActiveRecord::Base
  %w(n e s w).each { |d| belongs_to "user_#{d}", :class_name => "User", :extend => UserBoardExtension }
  has_many :bids, :order => "bids.position", :extend => BidsBoardExtension
  has_many :cards, :order => "cards.position", :extend => CardsBoardExtension
  has_many :claims

  delegate :n, :e, :s, :w, :owner, :to => :deal, :prefix => true, :allow_nil => true
  delegate :made?, :points, :result, :to => :score, :prefix => true, :allow_nil => true

  def deal
    Bridge::Deal.from_id(deal_id.to_i)
  rescue ArgumentError
  end

  def score
    Bridge::Score.new(:contract => contract, :vulnerable => declarer_vulnerable?, :tricks => tricks_taken(Bridge.side_of(declarer)))
  rescue ArgumentError
  end

  def dealer_number
    Bridge::DIRECTIONS.index(dealer)
  end

  def contract_trump
    contract_without_modifier.trump
  end

  def contract_suit
    contract_without_modifier.suit
  end

  def contract_without_modifier
    Bridge::Bid.new(contract.gsub(/(X+)/, ""))
  end

  def cards_left(direction = nil)
    users_cards = cards.inject(deal) do |current_cards, card|
      current_cards[card.user.direction].delete(card.card)
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

  def tricks_taken(side = nil)
    hash = cards.tricks.inject({}) do |h, trick|
      card = Bridge::Trick.new(trick.map(&:card)).winner(contract_trump)
      direction = deal_owner(card)
      h[direction] = (h[direction] || 0) + 1
      h
    end
    if side
      side.to_s.upcase.split("").inject(0) { |sum, direction| sum += hash[direction] }
    else
      hash
    end
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
end
