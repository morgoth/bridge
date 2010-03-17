class Table < ActiveRecord::Base
  has_many :players, :extend => PlayersTableExtension
  has_many :boards do
    def current
      order("position DESC").first
    end
  end

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :playing, :if => :four_players?
    end

    event :stop do
      transition :playing => :preparing, :unless => :four_players?
    end

    after_transition :on => :start, :do => :create_board!
  end

  def user_player(user)
    players.where(:user_id => user.id).first
  end

  def for_ajax(user)
    serializable_hash(:only => [:id, :state]).tap do |hash|

      if user && user_player(user)
        hash["player"] = user_player(user).direction
      end

      hash["players"] = Bridge::DIRECTIONS.inject({}) do |result, direction|
        player = players[direction]
        result[direction] = player.for_ajax if player
        result
      end

      hash["board"] = boards.last.present? ? boards.last.for_ajax : {}
    end
  end

  private

  def four_players?
    players.count == 4
  end

  def create_board!
    attributes = %w(n e s w).inject({}) do |hash, direction|
      hash.tap { |h| h["user_#{direction}"] = players[direction].user }
    end

    boards.create!(attributes)
  end
end
