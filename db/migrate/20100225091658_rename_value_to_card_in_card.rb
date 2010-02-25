class RenameValueToCardInCard < ActiveRecord::Migration
  def self.up
    rename_column :cards, :value, :card
  end

  def self.down
    rename_column :cards, :card, :value
  end
end
