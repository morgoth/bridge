class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :card, :presence => true
  validate :presence_of_card_in_hand, :correct_user, :state_of_board
  validate :identicalness_of_suit, :unless => :lead?

  delegate :deal, :card_played, :card_owner, :to => :board, :prefix => true
  delegate :suit, :value, :to => :card, :allow_nil => true

  after_create :board_card_played

  attr_writer :user

  def card
    Bridge::Card.new(read_attribute(:card))
  rescue ArgumentError
  end

  def card=(string)
    card = nil
    card = Bridge::Card.new(string).to_s
  rescue ArgumentError
  ensure
    write_attribute(:card, card)
  end

  def position
    read_attribute(:position) || (board.cards.count + 1)
  end

  def user
    @user ||= board_card_owner(card)
  end

  private

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
    return if previous_trick.empty?
    card = Bridge::Trick.new(previous_trick.map(&:card)).winner(board.trump)
    board_card_owner(card)
  end

  def expected_user
    if lead?
      previous_trick_winner || board.first_lead_user
    else
      board_card_owner(board.cards.last.card).next
    end
  end

  def cards_left_in_trick_suit?
    board.cards_left(@user.direction).any? { |c| c.suit == trick_suit }
  end

  def identicalness_of_suit
    errors.add(:card, "of card must be in #{trick_suit} suit") if suit != trick_suit and cards_left_in_trick_suit?
  end

  def presence_of_card_in_hand
    errors.add(:card, "#{card} doesn't belong to player") unless card_in_hand?
  end

  def card_in_hand?
    board.deal[@user.direction].include?(card)
  end

  def correct_user
    if user != expected_user
      errors.add :user, "can not play card at this moment"
    end
  end

  def state_of_board
    unless board && board.playing?
      errors.add :board, "is not in the playing state"
    end
  end
end
