class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    drop_table :users
    create_table(:users) do |t|
      t.authenticatable :encryptor => :sha1, :null => false
      t.rememberable
      t.trackable

      t.timestamps
    end

    add_index :users, :email,                :unique => true
  end

  def self.down
    drop_table :users
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.string :password_salt

      t.timestamps
    end
  end
end
