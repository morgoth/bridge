class AddAlertToBid < ActiveRecord::Migration
  def self.up
    add_column :bids, :alert, :string
  end

  def self.down
    remove_column :bids, :alert
  end
end
