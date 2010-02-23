class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :value, :presence => true
  validate :something, :if => :lead?

  delegate :deck, :to => :board, :prefix => true

  def position
    read_attribute(:position) || (board.cards.count + 1)
  end

  private

  def something
    true
  end

  def lead?
    position % 4 == 1
  end

  def not_lead?
    not lead?
  end
end
