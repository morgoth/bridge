class AddExplanationToClaim < ActiveRecord::Migration
  def self.up
    add_column :claims, :explanation, :string
  end

  def self.down
    remove_column :claims, :explanation
  end
end
