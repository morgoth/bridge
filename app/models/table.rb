class Table < ActiveRecord::Base
  extend ActiveSupport::Memoizable

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
  memoize :user_player

  def create_board!
    attributes = %w(n e s w).inject({}) do |hash, direction|
      hash.tap { |h| h["user_#{direction}"] = players[direction].user }
    end
    attributes[:deal_id] = Bridge::Deal.random_id.to_s
    attributes[:dealer] = Bridge.next_direction(boards.current.try(:dealer))
    attributes[:vulnerable] = Bridge.vulnerable_in_deal(boards.count + 1)

    boards.create!(attributes)
  end

  private

  def four_players?
    players.count == 4
  end
end
