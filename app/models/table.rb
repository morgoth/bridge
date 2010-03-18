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

    boards.create!(attributes)
  end
end
