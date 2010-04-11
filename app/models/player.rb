class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :table

  validates :user, :presence => true
  validates :user_id, :uniqueness => { :scope => :table_id }
  validates :table, :presence => true
  validates :direction, :presence => true, :inclusion => Bridge::DIRECTIONS, :uniqueness => { :scope => :table_id }

  delegate :start, :stop, :to => :table, :prefix => true
  delegate :name, :to => :user

  after_create :table_start
  after_destroy :table_stop
end
