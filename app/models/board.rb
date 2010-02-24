class Board < ActiveRecord::Base
  %w(n e s w).each { |d| belongs_to "user_#{d}", :class_name => "User", :extend => UserBoardExtension }
  has_many :cards, :order => "cards.position"
  has_many :bids, :order => "bids.position" do
    # active means beginning from the last contract
    def active
      where("position >= ?", contracts.last.try(:position) || 1)
    end

    def final
      with_suit(contracts.last).of_side(contracts.last)
    end
  end

  delegate :n, :e, :s, :w, :owner, :to => :deal, :prefix => true,
           :allow_nil => true

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
      current_cards[card.user.direction].delete(card.value)
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
