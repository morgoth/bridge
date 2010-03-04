class AddPointsNsAndTricksNsToBoard < ActiveRecord::Migration
  def self.up
    add_column :boards, :points_ns, :integer
    add_column :boards, :tricks_ns, :integer
  end

  def self.down
    remove_column :boards, :tricks_ns
    remove_column :boards, :points_ns
  end
end
