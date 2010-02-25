class RenameValueToBidInBid < ActiveRecord::Migration
  def self.up
    rename_column :bids, :value, :bid
  end

  def self.down
    rename_column :bids, :bid, :value
  end
end
