class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :card, :presence => true
  validate :presence_of_card_in_hand, :correct_user, :state_of_board
  validate :identicalness_of_suit, :unless => :current_lead?

  delegate :deal, :card_played, :card_owner, :cards, :cards_left, :deal, :playing?, :to => :board, :prefix => true
  delegate :suit, :value, :to => :card, :allow_nil => true
  delegate :current_trick_suit, :current_lead?, :current_user, :to => :board_cards

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

  def user
    @user ||= board_card_owner(card)
  end

  private

  def identicalness_of_suit
    if suit != current_trick_suit and current_user.has_cards_in_suit?(current_trick_suit)
      errors.add(:card, "of card must be in #{current_trick_suit} suit")
    end
  end

  def presence_of_card_in_hand
    errors.add(:card, "#{card} doesn't belong to player") unless current_user.has_card?(card)
  end

  # TODO: test that dummy user can't actually play cards
  def correct_user
    if (current_user.declarer? && user != current_user) || (current_user.dummy? && user != current_user.partner)
      errors.add :user, "can not play card at the moment"
    end
  end

  def state_of_board
    unless board_playing?
      errors.add :board, "is not in the playing state"
    end
  end
end
