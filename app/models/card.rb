class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :value, :presence => true, :inclusion => Bridge::DECK
  validate :presence_of_card_in_hand
  validate :identicalness_of_suit, :unless => :lead?

  delegate :deal, :to => :board, :prefix => true
  delegate :suit, :to => :bridge_card, :allow_nil => true

  def bridge_card
    Bridge::Card.new(value)
  rescue ArgumentError
  end

  def position
    read_attribute(:position) || (board.cards.count + 1)
  end

  def in_same_suit?(other)
    suit == other
  end

  def user_direction
    board.deal_owner(value)
  end

  def user
    board.users[user_direction]
  end

  def lead_position
    position - position % 4
  end

  def lead?
    position % 4 == 1
  end

  def lead
    board.cards.where(:position => lead_position).first
  end

  def trick
    board.cards.where(:position => lead_position...(lead_position + 4))
  end

  private

  def identicalness_of_suit
    errors.add(:value, "of card must be in #{board.cards.current_trick_suit} suit") if !in_same_suit?(board.cards.current_trick_suit) and cards_left_in_current_trick_suit?
  end

  def presence_of_card_in_hand
    errors.add(:value, "#{value} doesn't belong to player") unless card_in_hand?
  end

  def cards_left_in_current_trick_suit?
    board.cards_left(user.direction).any? { |c| c.suit == board.cards.current_trick_suit }
  end

  def card_in_hand?
    board.deal[user.direction].include?(value)
  end
end
