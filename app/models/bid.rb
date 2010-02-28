class Bid < ActiveRecord::Base
  belongs_to :board
  acts_as_list :scope => :board

  attr_writer :user

  validates :bid, :presence => true
  validates :board, :presence => true

  validate :contract_higher_than_last_contract,
           :has_opponents_contract_to_double,
           :has_opponents_double_to_redouble,
           :has_no_modifier_to_double, :has_no_redouble_to_redouble,
           :correct_user, :state_of_board

  scope :passes,    where(:bid => Bridge::PASS)
  scope :doubles,   where(:bid => Bridge::DOUBLE)
  scope :redoubles, where(:bid => Bridge::REDOUBLE)
  scope :modifiers, where(:bid => Bridge::MODIFIERS)
  scope :contracts, where(:bid => Bridge::CONTRACTS)
  scope :with_suit, lambda { |bid| where("bid LIKE ?", "_#{bid.respond_to?(:suit) ? bid.suit : bid}") }
  scope :of_side,   lambda { |bid| where("position % 2 = ? % 2", bid.respond_to?(:position) ? bid.position : bid) }

  delegate :bid_made, :to => :board, :prefix => true
  delegate :level, :suit, :trump, :pass?, :double?, :redouble?, :contract?, :to => :bid, :allow_nil => true

  after_create :board_bid_made

  def bid
    Bridge::Bid.new(read_attribute(:bid))
  rescue ArgumentError
  end

  def bid=(string)
    bid = nil
    bid = Bridge::Bid.new(string).to_s
  rescue ArgumentError
  ensure
    write_attribute(:bid, bid)
  end

  def user
    board && board.users[user_direction]
  end

  def position
    read_attribute(:position) || (board.bids.count + 1)
  end

  private

  alias :current_user :user

  def last_contract
    board && board.bids.contracts.last
  end

  def last_active_modifier
    board && board.bids.active.modifiers.last
  end

  def last_active_double
    board && board.bids.active.doubles.last
  end

  def last_active_redouble
    board && board.bids.active.redoubles.last
  end

  def partners_bid?(bid)
    bid.position % 2 == position % 2
  end

  def opponents_bid?(bid)
    !partners_bid?(bid)
  end

  def user_direction
    board && Bridge::DIRECTIONS[(board.dealer_number + position - 1) % 4]
  end

  def contract_higher_than_last_contract
    if last_contract && contract? && bid <= last_contract.bid
      errors.add :bid, "is not greater than the last contract"
    end
  end

  def has_opponents_contract_to_double
    if double? && (last_contract.nil? || partners_bid?(last_contract))
      errors.add :bid, "there is no opponent's contract to double"
    end
  end

  def has_opponents_double_to_redouble
    if redouble? && (last_active_double.nil? || partners_bid?(last_active_double))
      errors.add :bid, "there is no opponent's double to redouble"
    end
  end

  def has_no_modifier_to_double
    if double? && last_active_modifier
      errors.add :bid, "there is other modifier on the current contract"
    end
  end

  def has_no_redouble_to_redouble
    if redouble? && last_active_redouble
      errors.add :bid, "there is other redouble on the current contract"
    end
  end

  def correct_user
    if current_user != @user
      errors.add :user, "is not allowed to give a bid at the moment"
    end
  end

  def state_of_board
    unless board && board.auction?
      errors.add :board, "is not in the auction state"
    end
  end
end
