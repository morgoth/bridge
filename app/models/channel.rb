class Channel < ActiveRecord::Base
  has_many :messages, :order => "messages.position", :dependent => :destroy
end
