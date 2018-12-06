class AddDescriptionColumnToRecords < ActiveRecord::Migration[4.2]
  def self.up
  	add_column :records, :description, :text
  end

  def self.down
  	remove_column :records, :description
  end
end
