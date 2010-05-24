class CreateConcepts < ActiveRecord::Migration
  def self.up
    create_table :concepts, :options => 'default charset=utf8' do |t|
      t.string :title
      t.string :type
      t.integer :added_by
      t.integer :subject_area_id
      t.integer :country_id
      t.boolean :goout_intern

      t.timestamps
    end
  end

  def self.down
    drop_table :concepts
  end
end
