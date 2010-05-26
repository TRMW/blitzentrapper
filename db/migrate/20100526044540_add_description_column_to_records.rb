class AddDescriptionColumnToRecords < ActiveRecord::Migration
  def self.up
  	add_column :records, :description, :text
  end

  def self.down
  	remove_column :records, :description
  end
end
