class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :value, :presence => true
  validate :something, :if => :first_in_round?

  delegate :deck, :to => :board, :prefix => true

  def position
    read_attribute(:position) || (board.cards.count + 1)
  end

  private

  def something
    true
  end

  def first_in_round?
    position % 4 == 1
  end
end
