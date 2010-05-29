class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers, :options => 'default charset=utf8' do |t|
      t.string :body
      t.integer :user_id
      t.integer :question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
