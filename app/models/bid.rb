class Bid < ActiveRecord::Base
  belongs_to :board
  acts_as_list :scope => :board

  attr_writer :user

  validates :value, :presence => true, :inclusion => Bridge::BIDS
  validates :board, :presence => true

  validate :contract_higher_than_last_contract,
           :has_opponents_contract_to_double,
           :has_opponents_double_to_redouble,
           :has_no_modifier_to_double, :has_no_redouble_to_redouble,
           :correct_user

  before_validation { |bid| self.value = bid.value.to_s.upcase }

  scope :passes,    where(:value => Bridge::PASS)
  scope :doubles,   where(:value => Bridge::DOUBLE)
  scope :redoubles, where(:value => Bridge::REDOUBLE)
  scope :modifiers, where(:value => Bridge::MODIFIERS)
  scope :contracts, where(:value => Bridge::CONTRACTS)
  scope :with_suit, lambda { |bid| where("value LIKE ?", "_#{bid.respond_to?(:suit) ? bid.suit : bid}") }
  scope :of_side,   lambda { |bid| where("position % 2 = ? % 2", bid.respond_to?(:position) ? bid.position : bid) }

  delegate :level, :suit, :trump, :pass?, :double?, :redouble?,
           :contract?, :to => :bridge_bid, :allow_nil => true

  def bridge_bid
    Bridge::Bid.new(value)
  rescue ArgumentError # return nil if invalid or no bid
  end

  def position
    read_attribute(:position) || (board.bids.count + 1)
  end

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

  def user
    board && board.send("user_#{user_direction.downcase}")
  end

  private

  def contract_higher_than_last_contract
    if last_contract && contract? && bridge_bid <= last_contract.bridge_bid
      errors.add :value, "is not greater than the last contract"
    end
  end

  def has_opponents_contract_to_double
    if double? && (last_contract.nil? || partners_bid?(last_contract))
      errors.add :value, "there is no opponent's contract to double"
    end
  end

  def has_opponents_double_to_redouble
    if redouble? && (last_active_double.nil? || partners_bid?(last_active_double))
      errors.add :value, "there is no opponent's double to redouble"
    end
  end

  def has_no_modifier_to_double
    if double? && last_active_modifier
      errors.add :value, "there is other modifier on the current contract"
    end
  end

  def has_no_redouble_to_redouble
    if redouble? && last_active_redouble
      errors.add :value, "there is other redouble on the current contract"
    end
  end

  def correct_user
    if user != @user
      errors.add :user, "is not allowed to give a bid at the moment"
    end
  end
end
