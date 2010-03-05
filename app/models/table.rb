class Table < ActiveRecord::Base
  %w(n e s w).each { |d| belongs_to "player_#{d}", :class_name => "Player" }
  has_many :boards

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :playing, :if => :four_players_ready?
    end
  end

  def players
    [player_n, player_e, player_s, player_w]
  end

  private

  def four_players_ready?
    players.all? { |player| player && player.ready? }
  end
end
