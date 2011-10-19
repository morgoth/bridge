class CreateWebAccounts < ActiveRecord::Migration
  def change
    create_table :web_accounts do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.integer :user_id

      t.timestamps
    end
  end
end
