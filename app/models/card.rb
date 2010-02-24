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

  def in_same_suit?(other)
    suit == other
  end

  def suit
    value[0]
  end

  # TODO: FIXME
  def user
    direction = board.deal.owner(value)
    board.send("user_#{direction.downcase}")
  end

  def lead_position
    position - position % 4
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

  def lead?
    position % 4 == 1
  end

  def not_lead?
    not lead?
  end
end
