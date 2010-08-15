class AddPosts < ActiveRecord::Migration
  def self.up
 create_table "posts", :options => 'default charset=utf8', :force => true do |t|
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

  end

  def self.down
    drop_table :posts
  end
end
