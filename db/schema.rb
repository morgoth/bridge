# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100516205521) do

  create_table "bids", :force => true do |t|
    t.integer  "board_id"
    t.string   "bid"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alert"
  end

  create_table "boards", :force => true do |t|
    t.string   "state"
    t.string   "dealer"
    t.string   "vulnerable"
    t.string   "deal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_n_id"
    t.integer  "user_e_id"
    t.integer  "user_s_id"
    t.integer  "user_w_id"
    t.string   "declarer"
    t.string   "contract"
    t.integer  "points_ns"
    t.integer  "tricks_ns"
    t.integer  "table_id"
    t.integer  "position"
  end

  create_table "cards", :force => true do |t|
    t.integer  "board_id"
    t.string   "card"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "claims", :force => true do |t|
    t.integer  "tricks"
    t.string   "state"
    t.integer  "board_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "claiming_user_id"
    t.string   "explanation"
  end

  create_table "messages", :force => true do |t|
    t.string   "body"
    t.integer  "user_id"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "players", :force => true do |t|
    t.integer  "user_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "table_id"
    t.string   "direction"
  end

  create_table "tables", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :default => "", :null => false
    t.string   "encrypted_password",  :limit => 128, :default => "", :null => false
    t.string   "password_salt",                      :default => "", :null => false
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
