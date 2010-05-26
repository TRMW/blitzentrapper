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

ActiveRecord::Schema.define(:version => 20100526044540) do

  create_table "bt_posts", :primary_key => "post_id", :force => true do |t|
    t.integer  "topic_id",      :limit => 8,  :default => 1,     :null => false
    t.integer  "poster_id",                   :default => 0,     :null => false
    t.text     "post_text",                                      :null => false
    t.datetime "post_time",                                      :null => false
    t.string   "poster_ip",     :limit => 15, :default => "",    :null => false
    t.boolean  "post_status",                 :default => false, :null => false
    t.integer  "post_position", :limit => 8,  :default => 0,     :null => false
  end

  add_index "bt_posts", ["post_text"], :name => "post_text"
  add_index "bt_posts", ["post_time"], :name => "post_time"
  add_index "bt_posts", ["poster_id", "post_time"], :name => "poster_time"
  add_index "bt_posts", ["topic_id", "post_time"], :name => "topic_time"

  create_table "bt_topics", :primary_key => "topic_id", :force => true do |t|
    t.string   "topic_title",            :limit => 100, :default => "",          :null => false
    t.string   "topic_slug",                            :default => "",          :null => false
    t.integer  "topic_poster",           :limit => 8,   :default => 0,           :null => false
    t.string   "topic_poster_name",      :limit => 40,  :default => "Anonymous", :null => false
    t.integer  "topic_last_poster",      :limit => 8,   :default => 0,           :null => false
    t.string   "topic_last_poster_name", :limit => 40,  :default => "",          :null => false
    t.datetime "topic_start_time",                                               :null => false
    t.datetime "topic_time",                                                     :null => false
    t.integer  "forum_id",                              :default => 1,           :null => false
    t.boolean  "topic_status",                          :default => false,       :null => false
    t.boolean  "topic_open",                            :default => true,        :null => false
    t.integer  "topic_last_post_id",     :limit => 8,   :default => 1,           :null => false
    t.boolean  "topic_sticky",                          :default => false,       :null => false
    t.integer  "topic_posts",            :limit => 8,   :default => 0,           :null => false
    t.integer  "tag_count",              :limit => 8,   :default => 0,           :null => false
  end

  add_index "bt_topics", ["forum_id", "topic_time"], :name => "forum_time"
  add_index "bt_topics", ["topic_poster", "topic_start_time"], :name => "user_start_time"
  add_index "bt_topics", ["topic_slug"], :name => "topic_slug"
  add_index "bt_topics", ["topic_status", "topic_sticky", "topic_time"], :name => "stickies"

  create_table "bt_users", :primary_key => "ID", :force => true do |t|
    t.string "login",            :limit => 60,  :default => "", :null => false
    t.string "crypted_password",                :default => "", :null => false
    t.string "email",            :limit => 100, :default => "", :null => false
    t.string "url",              :limit => 100, :default => "", :null => false
  end

  add_index "bt_users", ["login"], :name => "user_login", :unique => true

  create_table "posts", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "topic_id"
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
  end

  create_table "setlistings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "show_id"
    t.integer  "song_id"
    t.integer  "track_number"
  end

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
    t.decimal  "latitude",      :precision => 9, :scale => 6
    t.decimal  "longitude",     :precision => 9, :scale => 6
    t.boolean  "festival_dupe"
  end

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
  end

  create_table "tracklistings", :force => true do |t|
    t.integer  "record_id"
    t.integer  "song_id"
    t.integer  "track_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                            :null => false
    t.string   "email"
    t.string   "url"
    t.string   "crypted_password"
    t.string   "password_salt",                    :null => false
    t.string   "persistence_token",                :null => false
    t.integer  "login_count",       :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
