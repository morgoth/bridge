class Board < ActiveRecord::Base
  %w(n e s w).each { |d| belongs_to "user_#{d}", :class_name => "User", :extend => UserBoardExtension }
  has_many :bids, :order => "bids.position", :extend => BidsBoardExtension
  has_many :cards, :order => "cards.position" do
    def trick(n)
      where(:position => ((n - 1) * 4 + 1)...(n * 4 + 1))
    end

    def tricks
      in_groups_of(4, false)
    end
  end

  delegate :n, :e, :s, :w, :owner, :to => :deal, :prefix => true, :allow_nil => true

  def deal
    Bridge::Deal.from_id(deal_id.to_i)
  rescue ArgumentError
  end

  def dealer_number
    Bridge::DIRECTIONS.index(dealer)
  end

  def trump
    bids.final.last.trump
  end

  def cards_left(direction = nil)
    users_cards = cards.inject(deal) do |current_cards, card|
      current_cards[card.user.direction].delete(card.card)
      current_cards = current_cards
    end
    direction.nil? ? users_cards : users_cards[direction]
  end

  def first_lead_user
    bids.final.first.user.next
  end

  def users
    [user_n, user_e, user_s, user_w].extend(UsersBoardExtension)
  end

  def tricks_taken
    cards.tricks.inject({}) do |result, trick|
      card = Bridge::Trick.new(trick.map(&:card)).winner(trump)
      direction = deal_owner(card)
      result[direction] = (result[direction] || 0) + 1
      result
    end
  end

  state_machine :initial => :auction do
    event :bid_made do
      transition :auction => :playing, :if => :passed?
    end
    event :card_played do
      transition :playing => :completed, :if => :cards_played?
    end

    # after_transition :auction => :playing, :do => :set_contract
    # after_transition :playing => :completed, :do => :set_result
  end
end
