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

ActiveRecord::Schema.define(:version => 20101204233041) do

  create_table "posts", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "postable_id"
    t.string   "postable_type"
    t.boolean  "visible",       :default => true
  end

  add_index "posts", ["postable_id"], :name => "index_posts_on_postable_id"
  add_index "posts", ["postable_type"], :name => "index_posts_on_postable_type"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["visible"], :name => "index_posts_on_visible"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "buy_buttons"
    t.string   "image_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "records", :force => true do |t|
    t.string   "title"
    t.date     "release_date"
    t.string   "label"
    t.text     "buy_buttons"
    t.text     "player"
    t.string   "edition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
    t.string   "cover_file_name"
  end

  create_table "setlistings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "show_id"
    t.integer  "song_id"
    t.integer  "position"
  end

  add_index "setlistings", ["show_id"], :name => "index_setlistings_on_show_id"
  add_index "setlistings", ["song_id"], :name => "index_setlistings_on_song_id"

  create_table "shows", :force => true do |t|
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.date     "date"
    t.time     "time"
    t.date     "enddate"
    t.string   "venue"
    t.string   "ticket_link"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bit_id"
    t.string   "status"
    t.decimal  "latitude",       :precision => 9, :scale => 6
    t.decimal  "longitude",      :precision => 9, :scale => 6
    t.boolean  "festival_dupe",                                :default => false
    t.date     "last_post_date"
    t.boolean  "manual",                                       :default => false
    t.boolean  "visible",                                      :default => true
    t.integer  "encore",                                       :default => 20
  end

  add_index "shows", ["visible"], :name => "index_shows_on_visible"

  create_table "songs", :force => true do |t|
    t.string   "title"
    t.text     "player"
    t.text     "lyrics"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sticky"
    t.boolean  "delete_me"
    t.datetime "last_post_date"
  end

  create_table "tracklistings", :force => true do |t|
    t.integer  "record_id"
    t.integer  "song_id"
    t.integer  "track_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracklistings", ["record_id"], :name => "index_tracklistings_on_record_id"
  add_index "tracklistings", ["song_id"], :name => "index_tracklistings_on_song_id"

  create_table "users", :force => true do |t|
    t.string   "login",                            :null => false
    t.string   "email"
    t.string   "url"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                :null => false
    t.integer  "login_count",       :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "delete_me"
    t.string   "location"
    t.string   "occupation"
    t.string   "interests"
    t.string   "slug"
    t.string   "avatar_file_name"
    t.string   "oauth2_token"
    t.string   "fbid"
  end

  add_index "users", ["oauth2_token"], :name => "index_users_on_oauth2_token"

end
