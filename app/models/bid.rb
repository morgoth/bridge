class Bid < ActiveRecord::Base
  belongs_to :board
  validates :value, :presence => true
  validates :board, :presence => true
  acts_as_list :scope => :board

  %w(1 2 3 4 5 6 7).inject([]) do |b, l|
    b += %w(C D H S NT).map { |s| l + s }
  end
end
