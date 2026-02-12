# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2018_07_08_201825) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "postable_id"
    t.string "postable_type"
    t.boolean "visible", default: true
    t.index ["postable_id"], name: "index_posts_on_postable_id"
    t.index ["postable_type"], name: "index_posts_on_postable_type"
    t.index ["user_id"], name: "index_posts_on_user_id"
    t.index ["visible"], name: "index_posts_on_visible"
  end

  create_table "records", id: :serial, force: :cascade do |t|
    t.string "title"
    t.date "release_date"
    t.string "label"
    t.text "buy_buttons"
    t.text "player"
    t.string "edition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.string "slug"
    t.string "cover_file_name"
  end

  create_table "setlistings", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "show_id"
    t.integer "song_id"
    t.integer "position"
    t.index ["show_id"], name: "index_setlistings_on_show_id"
    t.index ["song_id"], name: "index_setlistings_on_song_id"
  end

  create_table "shows", id: :serial, force: :cascade do |t|
    t.string "city"
    t.date "date"
    t.string "venue"
    t.string "ticket_link"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "bit_id"
    t.string "status"
    t.string "country"
    t.decimal "latitude"
    t.decimal "longitude"
    t.time "time"
    t.date "enddate"
    t.boolean "festival_dupe", default: false
    t.datetime "last_post_date"
    t.boolean "manual", default: false
    t.boolean "visible", default: true
    t.integer "encore", default: 20
    t.index ["visible"], name: "index_shows_on_visible"
  end

  create_table "songs", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "player"
    t.text "lyrics"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "sticky"
    t.datetime "last_post_date"
  end

  create_table "tracklistings", id: :serial, force: :cascade do |t|
    t.integer "records_id"
    t.integer "songs_id"
    t.integer "track_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["records_id"], name: "index_tracklistings_on_records_id"
    t.index ["songs_id"], name: "index_tracklistings_on_songs_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login", null: false
    t.string "email"
    t.string "url"
    t.string "crypted_password"
    t.string "password_salt"
    t.string "persistence_token", null: false
    t.integer "login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string "last_login_ip"
    t.string "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.string "location"
    t.string "occupation"
    t.string "interests"
    t.string "slug"
    t.string "avatar_file_name"
    t.string "oauth2_token"
    t.string "fbid"
    t.index ["oauth2_token"], name: "index_users_on_oauth2_token"
  end

  create_table "videos", id: :serial, force: :cascade do |t|
    t.string "hometown"
    t.text "description"
    t.string "clip_file_name"
    t.string "clip_content_type"
    t.integer "clip_file_size"
    t.datetime "clip_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
  end

end
