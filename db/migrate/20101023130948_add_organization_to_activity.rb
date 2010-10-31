class AddOrganizationToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :organization_id, :integer, :default => 0
  end

  def self.down
    remove_column :activities, :organization_id
  end
end
