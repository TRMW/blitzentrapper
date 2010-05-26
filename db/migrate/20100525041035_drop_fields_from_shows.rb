class DropFieldsFromShows < ActiveRecord::Migration
  def self.up
  	remove_column :shows, :ages
  	remove_column :shows, :support1
  	remove_column :shows, :support2
  	remove_column :shows, :support3
  end

  def self.down
  	add_column :shows, :ages
  	add_column :shows, :support1
  	add_column :shows, :support2
  	add_column :shows, :support3
  end
end
