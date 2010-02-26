class CreateClaims < ActiveRecord::Migration
  def self.up
    create_table :claims do |t|
      t.integer :tricks
      t.string :state
      t.integer :board_id

      t.timestamps
    end
  end

  def self.down
    drop_table :claims
  end
end
