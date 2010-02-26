class AddClaimingUserIdToClaim < ActiveRecord::Migration
  def self.up
    add_column :claims, :claiming_user_id, :integer
  end

  def self.down
    remove_column :claims, :claiming_user_id
  end
end
