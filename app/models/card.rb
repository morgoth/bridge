class Card < ActiveRecord::Base
  belongs_to :board
  validates :value, :presence => true
  acts_as_list :scope => :board
end
