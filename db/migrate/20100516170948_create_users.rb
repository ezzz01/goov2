class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :options => 'default charset=utf8' do |t|
      t.string :username
      t.string :crypted_password
      t.string :password_salt
      t.string :email
      t.string :persistence_token
      t.string :blog_url
      t.string :last_login_ip
      t.string :current_login_ip
      t.string :gender
      t.date :birthdate
      t.string :name
      t.string :surname
      t.integer :current_country

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
