class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions, :options => 'default charset=utf8' do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.string :cached_tag_list

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
