class Table < ActiveRecord::Base
  has_many :players
  has_many :boards

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :playing, :if => :four_players_ready?
    end
  end

  def user_player(user)
    players.where(:user_id => user.id).first
  end

  def for_ajax(user)
    serializable_hash(:only => [:id, :state]).tap do |hash|

      if user && user_player(user)
        hash["player"] = user_player(user).direction
      end

      hash["players"] = players.map(&:for_ajax)

      hash["board"] = boards.last.present? ? bards.last.for_ajax : {}
    end
  end

  private

  def four_players_ready?
    players.count == 4 && players.all?(&:ready?)
  end
end
