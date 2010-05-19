class AddChannelIdToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :channel_id, :integer
  end

  def self.down
    remove_column :tables, :channel_id
  end
end
