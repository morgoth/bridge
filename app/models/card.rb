class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :value, :presence => true, :inclusion => Bridge::DECK
  validate :presence_of_card_in_hand, :correct_user
  validate :identicalness_of_suit, :unless => :lead?

  delegate :deal, :to => :board, :prefix => true
  delegate :suit, :to => :bridge_card, :allow_nil => true

  attr_writer :user

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
    @user ||= board.users[user_direction]
  end

  def lead_position
    position - (position - 1) % 4
  end

  def previous_lead_position
    lead_position - 4
  end

  def lead?
    position == lead_position
  end

  def lead
    board.cards.where(:position => lead_position).first
  end

  def previous_lead
    board.cards.where(:position => previous_lead_position).first
  end

  def trick_suit
    lead.suit
  end

  def trick
    board.cards.where(:position => lead_position...(lead_position + 4))
  end

  def previous_trick
    board.cards.where(:position => previous_lead_position...(previous_lead_position + 4))
  end

  def previous_trick_suit
    previous_lead && previous_lead.suit
  end

  def previous_trick_winner
    card   = previous_trick.to_a.select { |c| c.suit == board.trump }.max { |a, b| a.bridge_card <=> b.bridge_card } if board.trump
    card ||= previous_trick.to_a.select { |c| c.suit == previous_trick_suit }.max { |a, b| a.bridge_card <=> b.bridge_card }
    return nil unless card
    direction = board.deal.owner(card.value)
    board.users[direction]
  end

  def expected_user
    if lead?
      previous_trick_winner || board.first_lead_user
    else
      direction = board.deal.owner(board.cards.last.value)
      board.users[direction].next
    end
  end

  private

  def cards_left_in_trick_suit?
    board.cards_left(@user.direction).any? { |c| c.suit == trick_suit }
  end

  def identicalness_of_suit
    errors.add(:value, "of card must be in #{trick_suit} suit") if !in_same_suit?(trick_suit) and cards_left_in_trick_suit?
  end

  def presence_of_card_in_hand
    errors.add(:value, "#{value} doesn't belong to player") unless card_in_hand?
  end

  def card_in_hand?
    board.deal[@user.direction].include?(value)
  end

  def correct_user
    if user != expected_user
      errors.add :user, "can not play card at this moment"
    end
  end
end
