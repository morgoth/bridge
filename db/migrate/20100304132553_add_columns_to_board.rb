class AddColumnsToBoard < ActiveRecord::Migration
  def self.up
    add_column :boards, :declarer, :string
    add_column :boards, :contract, :string
  end

  def self.down
    remove_column :boards, :contract
    remove_column :boards, :declarer
  end
end
