class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :value, :presence => true, :inclusion => Bridge::DECK
  validate :presence_of_card_in_hand
  validate :identicalness_of_suit, :if => :not_lead?

  delegate :deck, :to => :board, :prefix => true

  def position
    read_attribute(:position) || (board.cards.count + 1)
  end

  def last_card
    board && board.cards.last
  end

  def in_same_suit?(other)
    suit == other.suit
  end

  def suit
    value[0].downcase.to_sym
  end

  def user
    board && board.cards.user(position)
  end

  private

  def identicalness_of_suit
    errors.add("must play card in #{last_card.suit} suit") if !in_same_suit?(last_card) # and have other cards in suit
  end

  def presence_of_card_in_hand
    errors.add("card doesn't belongs to player") if false
  end

  def lead?
    position % 4 == 1
  end

  def not_lead?
    not lead?
  end
end
