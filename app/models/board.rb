class Board < ActiveRecord::Base
  has_many :cards, :order => "bids.position ASC"
  has_many :bids, :order => "bids.position ASC" do
    # active means beginning from the last contract
    def active
      where("position >= ?", contracts.last.try(:position) || 1)
    end
  end

  def deck
    Bridge.id_to_deal(deal_id.to_i)
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
