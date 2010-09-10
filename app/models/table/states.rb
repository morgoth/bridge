module Table::States
  extend ActiveSupport::Concern

  included do
    state_machine :initial => :preparing do
      event :start do
        transition :preparing => :playing, :if => :four_players?
      end

      event :stop do
        transition :playing => :preparing, :unless => :four_players?
      end

      after_transition :on => :start, :do => :create_board!
    end
  end
end
