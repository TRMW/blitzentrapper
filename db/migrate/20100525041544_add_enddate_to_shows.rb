class AddEnddateToShows < ActiveRecord::Migration
  def self.up
  	add_column :shows, :endate, :date
  end

  def self.down
  	remove_column :shows, :endate
  end
end
