class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :value, :presence => true, :inclusion => Bridge::DECK
  validate :presence_of_card_in_hand
  validate :identicalness_of_suit, :if => :not_lead?

  delegate :deal, :to => :board, :prefix => true

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
    value[0]
  end

  def user
    board && board.cards.user(position)
  end

  private

  def identicalness_of_suit
    errors.add(:value, "of card must be in #{last_card.suit} suit") if !in_same_suit?(last_card) and cards_left_in_suit?
  end

  def presence_of_card_in_hand
    errors.add(:value, "#{value} doesn't belongs to player") unless card_in_hand?
  end

  def cards_left_in_suit?
    board.cards_left(user.direction).any? { |c| c[0] == last_card.suit }
  end

  def card_in_hand?
    board.send("#{user.direction.downcase}_hand").include?(value)
  end

  def lead?
    position % 4 == 1
  end

  def not_lead?
    not lead?
  end
end
