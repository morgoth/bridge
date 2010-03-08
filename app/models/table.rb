class Table < ActiveRecord::Base
  has_many :players
  has_many :boards

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :playing, :if => :four_players_ready?
    end
  end

  private

  def four_players_ready?
    players.count == 4 && players.all?(&:ready?)
  end
end
