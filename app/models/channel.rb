class Channel < ActiveRecord::Base
  include OldTouch

  has_many :messages, :order => "messages.position", :dependent => :destroy
end
