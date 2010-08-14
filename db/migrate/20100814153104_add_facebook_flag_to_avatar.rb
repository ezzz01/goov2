class AddFacebookFlagToAvatar < ActiveRecord::Migration
  def self.up
    add_column :avatars, :fb_avatar, :boolean, :default => 0
  end

  def self.down
    remove_column :avatars, :fb_avatar
  end
end
