class Table < ActiveRecord::Base
  has_many :players, :extend => PlayersTableExtension
  has_many :boards, :extend => BoardsTableExtension

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
    user && players.where(:user_id => user.id).first
  end

  private

  def four_players?
    players.count == 4
  end

  def create_board!
    attributes = %w(n e s w).inject({}) do |hash, direction|
      hash.tap { |h| h["user_#{direction}"] = players[direction].user }
    end
    attributes[:deal_id] = Bridge::Deal.random_id.to_s
    attributes[:dealer] = next_direction(boards.current.try(:dealer))
    attributes[:vulnerable] = next_vulnerable(boards.current.try(:vulnerable))

    boards.create!(attributes)
  end

  private

  def four_players?
    players.count == 4
  end

  # TODO: move to gem
  def next_direction(direction)
    return Bridge::DIRECTIONS.first if direction.nil?
    i = (Bridge::DIRECTIONS.index(direction) + 1) % 4
    Bridge::DIRECTIONS[i]
  end

  def next_vulnerable(vulnerable)
    return Bridge::VULNERABILITIES.first if vulnerable.nil?
    i = (Bridge::VULNERABILITIES.index(vulnerable) + 1) % 4
    Bridge::VULNERABILITIES[i]
  end
end
