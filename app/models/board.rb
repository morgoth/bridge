class Board < ActiveRecord::Base
  %w(n e s w).each { |d| belongs_to "user_#{d}", :class_name => "User", :extend => UserBoardExtension }
  has_many :bids, :order => "bids.position", :extend => BidsBoardExtension
  has_many :cards, :order => "cards.position" do
    def trick(n)
      where(:position => ((n - 1) * 4 + 1)...(n * 4 + 1)).all
    end

    def tricks
      in_groups_of(4, false)
    end

    # Count completed tricks
    # TODO: test
    def completed_tricks_count
      count.div(4)
    end

    def current_position
      count + 1
    end

    def current_lead_position
      current_position - (current_position - 1) % 4
    end

    def previous_lead_position
      current_lead_position - 4
    end

    def current_lead?
      current_position == current_lead_position
    end

    def previous_lead
      where(:position => previous_lead_position).first
    end

    def current_lead
      where(:position => current_lead_position).first
    end

    def current_trick_suit
      current_lead && current_lead.suit
    end

    def current_trick
      where(:position => current_lead_position...(current_lead_position + 4))
    end

    def previous_trick
      where(:position => previous_lead_position...(previous_lead_position + 4))
    end

    def previous_trick_suit
      previous_lead && previous_lead.suit
    end

    def previous_trick_winner
      return if previous_trick.empty?
      card = Bridge::Trick.new(previous_trick.map(&:card)).winner(proxy_owner.trump)
      proxy_owner.card_owner(card)
    end

    def current_user
      if current_lead?
        previous_trick_winner || proxy_owner.first_lead_user
      else
        proxy_owner.card_owner(last.card).next
      end
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

  def card_owner(card)
    direction = deal_owner(card)
    users[direction]
  end

  # TODO: test
  def declarer_user
    bids.final.first.user
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
      card = Bridge::Trick.new(trick.map(&:card)).winner(trump)
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

  state_machine :initial => :auction do
    event :bid_made do
      transition :auction => :completed, :if => :four_passes?
      transition :auction => :playing, :if => :end_of_auction?
    end

    event :card_played do
      transition :playing => :completed, :if => :end_of_play?
    end
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
end
