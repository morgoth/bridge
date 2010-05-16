class AddPositionToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :position, :integer
  end

  def self.down
    remove_column :messages, :position
  end
end
