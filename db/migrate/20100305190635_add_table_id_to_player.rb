class AddTableIdToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :table_id, :integer
  end

  def self.down
    remove_column :players, :table_id
  end
end
