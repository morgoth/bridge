class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :tables do |t|
      t.integer :player_n, :player_e, :player_s, :player_w

      t.timestamps
    end
  end

  def self.down
    drop_table :tables
  end
end
