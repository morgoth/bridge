class AddVersionToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :version, :integer, :default => 0
  end

  def self.down
    remove_column :tables, :version
  end
end
