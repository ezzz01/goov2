class CreateUserSessions < ActiveRecord::Migration
  def self.up
    create_table :user_sessions, :options => 'default charset=utf8' do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :user_sessions
  end
end
