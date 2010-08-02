class AddFacebookToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :fb_user_id, :integer, :default => 0
      add_column :users, :email_hash, :string, :limit => 64, :null => true
  end

  def self.down
    remove_column :users, :fb_user_id
    remove_column :users, :email_hash
  end
end
