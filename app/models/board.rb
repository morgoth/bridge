class Board < ActiveRecord::Base
  belongs_to :user_n, :class_name => "User"
  belongs_to :user_e, :class_name => "User"
  belongs_to :user_s, :class_name => "User"
  belongs_to :user_w, :class_name => "User"
  has_many :cards, :order => "bids.position ASC"
  has_many :bids, :order => "bids.position ASC" do
    # active means beginning from the last contract
    def active
      where("position >= ?", contracts.last.try(:position) || 1)
    end

    def final
      with_suit(contracts.last).of_side(contracts.last)
    end
  end

  def deck
    Bridge.id_to_deal(deal_id.to_i)
  end

  def dealer_offset
    ["N", "E", "S", "W"].index(dealer)
  end

  def nth_bid_user(n)

  end

  [:n, :e, :s, :w].each do |hand|
    define_method("#{hand}_hand") do
      deck[hand]
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
