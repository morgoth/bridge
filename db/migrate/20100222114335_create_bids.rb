class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.integer :board_id
      t.string :value
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
