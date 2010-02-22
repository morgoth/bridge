class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.integer :board_id
      t.string :value
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end
