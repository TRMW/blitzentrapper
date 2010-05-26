class AddFestivalDupeColumnToShows < ActiveRecord::Migration
  def self.up
  	add_column :shows, :festival_dupe, :boolean
  end

  def self.down
  	remove_column :shows, :festival_dupe
  end
end
