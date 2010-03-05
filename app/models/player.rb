class Player < ActiveRecord::Base
  belongs_to :user
  has_one :table

  state_machine :initial => :preparing do
    event :start do
      transition :preparing => :ready
    end
  end
end
