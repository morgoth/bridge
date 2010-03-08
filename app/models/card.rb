class Card < ActiveRecord::Base
  acts_as_list :scope => :board
  belongs_to :board

  validates :card, :presence => true, :uniqueness => { :scope => :board_id }
  validate :presence_of_card_in_hand, :correct_user, :state_of_board
  validate :identicalness_of_suit, :unless => :current_lead?

  delegate :claims, :deal, :card_played, :card_owner, :cards, :cards_left, :deal, :playing?, :to => :board, :prefix => true
  delegate :suit, :value, :to => :card, :allow_nil => true
  delegate :current_trick_suit, :current_lead?, :current_user, :to => :board_cards

  after_create :board_card_played
  after_create { |card| card.board.claims.active.each { |claim| claim.user = card.user; claim.reject! } }

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

  def reject_active_claims
    board_claims.active.each do |claim|
      claim.user = user
      claim.reject!
    end
  end

  def identicalness_of_suit
    if suit != current_trick_suit && current_user.has_cards_in_suit?(current_trick_suit)
      errors.add(:card, "of card must be in #{current_trick_suit} suit")
    end
  end

  def presence_of_card_in_hand
    unless current_user.has_card?(card)
      errors.add(:card, "#{card} doesn't belong to player")
    end
  end

  def correct_user
    if (!current_user.dummy? && user != current_user) || (current_user.dummy? && user != current_user.partner)
      errors.add(:user, "can not play card at the moment")
    end
  end

  def state_of_board
    unless board_playing?
      errors.add(:board, "is not in the playing state")
    end
  end
end
