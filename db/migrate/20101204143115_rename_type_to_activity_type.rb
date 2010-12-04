class RenameTypeToActivityType < ActiveRecord::Migration
  def self.up
      rename_column :activities, :type, :activity_type
  end

  def self.down
      rename_column :activities, :activity_type, :activity
  end
end
