class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
      t.string :state
      t.string :dealer
      t.string :vulnerable
      t.string :deal_id

      t.timestamps
    end
  end

  def self.down
    drop_table :boards
  end
end
