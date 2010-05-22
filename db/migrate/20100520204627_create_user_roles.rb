class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.integer :user
      t.integer :role

      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
