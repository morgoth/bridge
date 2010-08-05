class Table < ActiveRecord::Base
  has_many :players, :extend => PlayersTableExtension
  has_many :boards, :extend => BoardsTableExtension
  belongs_to :channel

  after_touch :increment_version
  after_save :increment_version
  before_create :create_channel

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :playing, :if => :four_players?
    end

    event :stop do
      transition :playing => :preparing, :unless => :four_players?
    end

    after_transition :on => :start, :do => :create_board!
  end

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

  def increment_version
    update_attribute("version", version.to_i + 1)
  end

  def four_players?
    players.count == 4
  end
end
