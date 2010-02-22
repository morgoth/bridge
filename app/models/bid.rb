class Bid < ActiveRecord::Base
  CONTRACTS = %w(1 2 3 4 5 6 7).inject([]) do |b, l|
    b += %w(C D H S NT).map { |s| l + s }
  end
  MODIFIERS = %w(X XX)
  PASS = %w(PASS)
  BIDS = CONTRACTS + MODIFIERS + PASS

  belongs_to :board
  validates :value, :presence => true, :inclusion => BIDS
  validates :board, :presence => true
  acts_as_list :scope => :board

  scope :contracts, { :conditions => { :value => CONTRACTS } }
  scope :modifiers, { :conditions => { :value => MODIFIERS } }
  scope :passes,    { :conditions => { :value => PASS      } }

  before_validation { |bid| self.value = bid.value.to_s.upcase }

  def pass?
    PASS.include?(value)
  end

  def modifier?
    MODIFIERS.include?(value)
  end

  def contract?
    CONTRACTS.include?(value)
  end

  def higher_than_last_contract?
    last_contract = board.bids.contracts.last
    if last_contract.nil? or not contract?
      true
    else
      CONTRACTS.index(value) > CONTRACTS(last_contract.value)
    end
  end
end
