class Board < ActiveRecord::Base
  has_many :cards, :order => "bids.position ASC"
  has_many :bids, :order => "bids.position ASC"

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
