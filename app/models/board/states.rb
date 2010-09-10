module Board::States
  extend ActiveSupport::Concern

  included do
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
      after_transition any => :completed do |board, transition|
        board.table_create_board!
      end
    end
  end
end
