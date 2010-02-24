class Board < ActiveRecord::Base
  belongs_to :user_n, :class_name => "User", :extend => UserBoardExtension
  belongs_to :user_e, :class_name => "User", :extend => UserBoardExtension
  belongs_to :user_s, :class_name => "User", :extend => UserBoardExtension
  belongs_to :user_w, :class_name => "User", :extend => UserBoardExtension
  has_many :cards, :order => "cards.position ASC" do
    def current_position
      proxy_target.count + 1
    end

    def current_lead_position
      ((current_position - 1) - (current_position - 1) % 4) + 1
    end

    def current_lead
      where(:position => current_lead_position).first
    end

    def current_trick
      where(:position => current_lead_position...(current_lead_position + 4))
    end

    def current_trick_suit
      current_lead.suit
    end

    def current_lead?
      current_position % 4 == 1
    end

    def current_user
      if current_lead?
        last_trick_winner || first_lead_user
      else
        direction = proxy_owner.deal.owner(proxy_owner.cards.last.value)
        proxy_owner.send("user_#{direction.downcase}")
      end
    end

    def last_trick
      where(:position => (current_lead_position - 4)...current_lead_position)
    end

    def last_trick_winner
      c = proxy_owner.cards.last_trick.select { |c| c.suit == proxy_owner.trump }.max if proxy_owner.trump
      c ||= proxy_owner.cards.last_trick.select { |c| c.suit == proxy_owner.cards.last_trick.first.suit }.max
      direction = proxy_owner.deal.owner(c.value)
      proxy_owner.send("user_#{direction.downcase}")
    end
  end

  has_many :bids, :order => "bids.position ASC" do
    # active means beginning from the last contract
    def active
      where("position >= ?", contracts.last.try(:position) || 1)
    end

    def final
      with_suit(contracts.last).of_side(contracts.last)
    end
  end

  delegate :n, :e, :s, :w, :to => :deal, :prefix => true,
           :allow_nil => true

  def deal
    Bridge::Deal.from_id(deal_id.to_i)
  rescue ArgumentError
  end

  def dealer_number
    Bridge::DIRECTIONS.index(dealer)
  end

  def trump
    bids.final.last.suit == "NT" ? nil : bids.final.last.suit
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
