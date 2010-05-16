class Claim < ActiveRecord::Base
  belongs_to :board, :touch => true
  belongs_to :claiming_user, :class_name => "User", :extend => ClaimingUserClaimExtension

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

  delegate :claims, :cards, :users, :to => :board, :prefix => true
  delegate :current_user, :completed_tricks_count, :to => :board_cards

  before_validation lambda { |claim| claim.claiming_user = claim.user }, :if => :new_record?
  before_validation lambda { |claim| claim.state_event = :propose }, :if => :new_record?
  after_save { |claim| claim.board.claimed }
  after_create :reject_active_claims

  attr_accessor :user

  state_machine do
    event :propose do
      transition nil => :previous_accepted, :if => :previous_user_dummy?
      transition nil => :next_accepted, :if => :next_user_dummy?
      transition nil => :proposed, :if => :user_declarer?
    end
    event :accept do
      transition :proposed => :previous_accepted, :if => :user_previous?
      transition :proposed => :next_accepted, :if => :user_next?
      transition :previous_accepted => :accepted, :if => :user_next?
      transition :next_accepted => :accepted, :if => :user_previous?
    end
    event :reject do
      transition [:proposed, :previous_accepted, :next_accepted] => :rejected, :if => :playing_user?
    end
  end

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
