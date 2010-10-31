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

ActiveRecord::Schema.define(:version => 20101023130948) do

  create_table "activities", :force => true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "study_program_id"
    t.integer  "exchange_program_id"
    t.integer  "activity_area_id"
    t.date     "from"
    t.date     "to"
    t.boolean  "current"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id",     :default => 0
  end

  create_table "answers", :force => true do |t|
    t.string   "body"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "avatars", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fb_avatar",    :default => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "in_reply_to_id"
  end

  create_table "concepts", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "pending",         :default => true
    t.integer  "added_by"
    t.integer  "subject_area_id"
    t.integer  "country_id"
    t.boolean  "goout_intern",    :default => false
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "cached_tag_list"
    t.string   "guid"
    t.string   "url"
    t.string   "from_url"
    t.boolean  "deleted",         :default => false
  end

  create_table "questions", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.string   "cached_tag_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "revisions", :force => true do |t|
    t.text     "content"
    t.integer  "author_id"
    t.integer  "concept_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "email"
    t.string   "persistence_token"
    t.string   "blog_url"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "gender"
    t.date     "birthdate"
    t.string   "name"
    t.string   "surname"
    t.integer  "current_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fb_user_id",                       :default => 0
    t.string   "email_hash",         :limit => 64
    t.string   "session_key"
  end

  create_table "votes", :force => true do |t|
    t.integer  "voteable_id"
    t.integer  "user_id"
    t.string   "voteable_type"
    t.integer  "vote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wiki_references", :force => true do |t|
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "concept_id",                    :default => 0,  :null => false
    t.string   "referenced_name", :limit => 60, :default => "", :null => false
    t.string   "link_type",       :limit => 1,  :default => "", :null => false
  end

end
