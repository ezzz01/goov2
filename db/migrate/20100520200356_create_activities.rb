class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :type
      t.integer :user_id
      t.integer :study_program_id
      t.integer :exchange_program_id
      t.integer :activity_area_id
      t.date :from
      t.date :to
      t.boolean :current
      t.integer :country_id

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
