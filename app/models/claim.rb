class Claim < ActiveRecord::Base
  belongs_to :board
  belongs_to :claiming_user, :class_name => "User", :extend => ClaimingUserClaimExtension

  attr_accessor :user

  validates :board, :presence => true
  validates :tricks, :presence => true, :numericality => true
  validates :state, :presence => true

  validate :tricks_number_below_maximum
  # TODO: should user be able to claim in any moment of game?
  # validate :correct_user

  delegate :cards, :to => :board, :prefix => true
  delegate :current_user, :completed_tricks_count, :to => :board_cards

  scope :proposed, where(:state => "proposed")
  scope :accepted, where(:state => "accepted")
  scope :previous_accepted, where(:state => "previous_accepted")
  scope :next_accepted, where(:state => "next_accepted")
  scope :rejected, where(:state => "rejected")

  after_create :autoaccept_by_dummy

  state_machine :initial => :proposed do
    event :accept do
      transition :proposed => :previous_accepted, :if => :user_previous?
      transition :proposed => :next_accepted, :if => :user_next?
      transition :previous_accepted => :accepted, :if => :user_next?
      transition :next_accepted => :accepted, :if => :user_previous?
    end
    event :reject do
      # TODO: validate user reject
      transition [:proposed, :previous_accepted, :next_accepted] => :rejected
    end
  end

  private

  def autoaccept_by_dummy
    if claiming_user.previous.dummy?
      self.user = claiming_user.previous
      accept!
    elsif claiming_user.next.dummy?
      self.user = claiming_user.next
      accept!
    end
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

  # def correct_user
  #  if claiming_user != current_user
  #    errors.add :user, "can not claim at the moment"
  #  end
  # end
end
