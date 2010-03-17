class AddPositionToBoard < ActiveRecord::Migration
  def self.up
    add_column :boards, :position, :integer
  end

  def self.down
    remove_column :boards, :position
  end
end
