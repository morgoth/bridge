class Bid < ActiveRecord::Base
  # TODO: move to the gem
  CONTRACTS = %w(1 2 3 4 5 6 7).inject([]) do |b, l|
    b += %w(C D H S NT).map { |s| l + s }
  end
  PASS = "PASS"
  DOUBLE = "X"
  REDOUBLE = "XX"
  MODIFIERS = [DOUBLE, REDOUBLE]
  BIDS = CONTRACTS + MODIFIERS + [PASS]
  # ODOT

  belongs_to :board
  acts_as_list :scope => :board

  validates :value, :presence => true, :inclusion => BIDS
  validates :board, :presence => true

  validate :contract_higher_than_last_contract,
           :has_opponents_contract_to_double,
           :has_opponents_double_to_redouble,
           :has_no_modifier_to_double, :has_no_redouble_to_redouble

  before_validation { |bid| self.value = bid.value.to_s.upcase }

  scope :passes,    where(:value => PASS)
  scope :doubles,   where(:value => DOUBLE)
  scope :redoubles, where(:value => REDOUBLE)
  scope :modifiers, where(:value => MODIFIERS)
  scope :contracts, where(:value => CONTRACTS)
  scope :with_suit, lambda { |bid| where("value LIKE ?", "_#{bid.respond_to?(:suit) ? bid.suit : bid}") }
  scope :of_side,   lambda { |bid| where("position % 2 = ? % 2", bid.respond_to?(:position) ? bid.position : bid) }

  def level
    value[0] if contract?
  end

  def suit
    value[1..-1] if contract?
  end

  def position
    read_attribute(:position) || (board.bids.count + 1)
  end

  def pass?
    value == PASS
  end

  def double?
    value == DOUBLE
  end

  def redouble?
    value == REDOUBLE
  end

  def contract?
    CONTRACTS.include?(value)
  end

  def contract_compare(other)
    CONTRACTS.index(value) <=> CONTRACTS.index(other.value)
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

  private

  def contract_higher_than_last_contract
    if last_contract && contract? && contract_compare(last_contract) <= 0
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
end
