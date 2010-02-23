class AddUsersToBoard < ActiveRecord::Migration
  def self.up
    add_column :boards, :user_n_id, :integer
    add_column :boards, :user_e_id, :integer
    add_column :boards, :user_s_id, :integer
    add_column :boards, :user_w_id, :integer
  end

  def self.down
    remove_column :boards, :user_w_id
    remove_column :boards, :user_s_id
    remove_column :boards, :user_e_id
    remove_column :boards, :user_n_id
  end
end
