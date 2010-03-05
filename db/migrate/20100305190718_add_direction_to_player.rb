class AddDirectionToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :direction, :string
  end

  def self.down
    remove_column :players, :direction
  end
end
