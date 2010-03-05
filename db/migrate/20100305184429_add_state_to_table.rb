class AddStateToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :state, :string
  end

  def self.down
    remove_column :tables, :state
  end
end
