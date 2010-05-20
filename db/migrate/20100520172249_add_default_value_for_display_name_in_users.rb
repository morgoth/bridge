class AddDefaultValueForDisplayNameInUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      if user.display_name.nil?
        user.update_attributes!(:display_name => user.email.split("@").first)
      end
    end
  end

  def self.down
  end
end
