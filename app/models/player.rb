class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :table

  validates :user, :presence => true
  validates :table, :presence => true
  validates :direction, :presence => true, :inclusion => Bridge::DIRECTIONS

  validates_uniqueness_of :user_id, :scope => :table_id
  validates_uniqueness_of :direction, :scope => :table_id

  delegate :start, :to => :table, :prefix => true
  delegate :name, :to => :user

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :ready
    end

    event :reset do
      transition all => :preparing
    end

    after_transition :on => :start, :do => :table_start
  end

  def for_ajax
    serializable_hash(:only => [:direction, :state], :methods => ["name"])
  end
end
