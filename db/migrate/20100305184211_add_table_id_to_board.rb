class AddTableIdToBoard < ActiveRecord::Migration
  def self.up
    add_column :boards, :table_id, :integer
  end

  def self.down
    remove_column :boards, :table_id
  end
end
