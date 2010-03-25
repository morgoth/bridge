class Bid < ActiveRecord::Base
  belongs_to :board
  acts_as_list :scope => :board

  attr_writer :user

  validates :bid, :presence => true
  validates :board, :presence => true

  validate :contract_higher_than_last_contract, :double_allowed,
           :redouble_allowed, :correct_user, :state_of_board

  scope :passes,    where(:bid => Bridge::PASS)
  scope :doubles,   where(:bid => Bridge::DOUBLE)
  scope :redoubles, where(:bid => Bridge::REDOUBLE)
  scope :modifiers, where(:bid => Bridge::MODIFIERS)
  scope :contracts, where(:bid => Bridge::CONTRACTS)
  scope :with_suit, lambda { |bid| where("bid LIKE ?", "_#{bid.respond_to?(:suit) ? bid.suit : bid}") }
  scope :of_side,   lambda { |bid| where("position % 2 = ? % 2", bid.respond_to?(:position) ? bid.position : bid) }

  delegate :bid_made, :bids, :to => :board, :prefix => true
  delegate :level, :suit, :trump, :pass?, :double?, :redouble?, :contract?, :to => :bid, :allow_nil => true
  delegate :current_contract, :double_allowed?, :redouble_allowed?, :to => :board_bids

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

  def user_direction
    board && Bridge::DIRECTIONS[(board.dealer_number + position - 1) % 4]
  end

  def contract_higher_than_last_contract
    if current_contract && contract? && bid <= current_contract.bid
      errors.add :bid, "is not greater than the last contract"
    end
  end

  def double_allowed
    if double? && !double_allowed?
      errors.add :bid, "double is not allowed at the moment"
    end
  end

  def redouble_allowed
    if redouble? && !redouble_allowed?
      errors.add :bid, "redouble is not allowed at the moment"
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
