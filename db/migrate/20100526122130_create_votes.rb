class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes, :options => 'default charset=utf8' do |t|
      t.integer :voteable_id
      t.integer :user_id
      t.string :voteable_type
      t.integer :vote

      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
