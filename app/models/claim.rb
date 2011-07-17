class Claim < ActiveRecord::Base
  include Claim::States

  belongs_to :board, :touch => true
  belongs_to :claiming_user, :class_name => "User"

  validates :board, :presence => true
  validates :tricks, :presence => true, :numericality => true
  validate :tricks_number_below_maximum
  validate :correct_user

  scope :active, where(:state => ["proposed", "previous_accepted", "next_accepted"])
  scope :proposed, where(:state => "proposed")
  scope :accepted, where(:state => "accepted")
  scope :previous_accepted, where(:state => "previous_accepted")
  scope :next_accepted, where(:state => "next_accepted")
  scope :rejected, where(:state => "rejected")

  delegate :claims, :cards, :users, :declarer, :to => :board, :prefix => true
  delegate :current_user, :completed_tricks_count, :to => :board_cards

  before_validation lambda { |claim| claim.claiming_user = claim.user }, :if => :new_record?
  before_validation lambda { |claim| claim.state_event = :propose }, :if => :new_record?
  after_save { |claim| claim.board.claimed }
  after_create :reject_active_claims

  attr_accessor :user

  def claiming_user_with_augmentation
    board.users.find { |user| user.id == claiming_user_id }
  end
  alias_method_chain :claiming_user, :augmentation

  def concerned_users
    board_users.tap do |users|
      users.delete(claiming_user.partner)
      users.delete(claiming_user.next)     if next_accepted?
      users.delete(claiming_user.previous) if previous_accepted?
    end
  end

  def accept_users
    concerned_users.tap { |users| users.delete(claiming_user) }
  end
  alias_method :reject_users, :accept_users

  def declarer_total_tricks
    total = tricks + board.tricks_taken(Bridge.side_of(claiming_user.direction))
    user_declarer? ? total : 13 - total
  end

  private

  def user_declarer?
    claiming_user.declarer?
  end

  def previous_user_dummy?
    claiming_user.previous.dummy?
  end

  def next_user_dummy?
    claiming_user.next.dummy?
  end

  def playing_user?
    board_users.without_dummy.include?(user)
  end

  def user_previous?
    claiming_user.previous == user
  end

  def user_next?
    claiming_user.next == user
  end

  def tricks_number_below_maximum
    if tricks > (13 - completed_tricks_count)
      errors.add :tricks, "claimed tricks number exceeds 13"
    end
  end

  def correct_user
    unless playing_user?
      errors.add :user, "can not claim"
    end
  end

  def reject_active_claims
    board_claims.active.where("id != ?", id).each do |claim|
      claim.user = user
      claim.reject!
    end
  end
end
