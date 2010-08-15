class AddComments < ActiveRecord::Migration
  def self.up
    create_table "comments", :options => 'default charset=utf8', :force => true do |t|
      t.integer  "post_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "in_reply_to_id"
    end
  end

  def self.down
    drop_table "comments"
  end
end
