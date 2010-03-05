class RemovePlayersFromTable < ActiveRecord::Migration
  def self.up
    remove_column :tables, :player_n
    remove_column :tables, :player_e
    remove_column :tables, :player_s
    remove_column :tables, :player_w
  end

  def self.down
    add_column :tables, :player_n, :integer
    add_column :tables, :player_e, :integer
    add_column :tables, :player_s, :integer
    add_column :tables, :player_w, :integer
  end
end
