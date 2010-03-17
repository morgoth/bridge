class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :table

  validates :user, :presence => true
  validates :table, :presence => true
  validates :direction, :presence => true, :inclusion => Bridge::DIRECTIONS

  validates_uniqueness_of :user_id, :scope => :table_id
  validates_uniqueness_of :direction, :scope => :table_id

  delegate :start, :stop, :to => :table, :prefix => true
  delegate :name, :to => :user

  after_create :table_start
  after_destroy :table_stop

  def for_ajax
    serializable_hash(:only => [:state], :methods => ["name"])
  end
end
