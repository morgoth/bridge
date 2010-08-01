class Message < ActiveRecord::Base
  include OldTouch

  belongs_to :user
  belongs_to :channel, :touch => true
  acts_as_list :scope => :channel

  validates :body, :presence => true
  validates :user, :presence => true
  validates :channel, :presence => true

  scope :after_position, lambda { |position| where("position > ?", position) }

  delegate :name, :to => :user, :prefix => true
end
