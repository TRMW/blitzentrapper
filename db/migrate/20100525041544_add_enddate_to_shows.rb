class AddEnddateToShows < ActiveRecord::Migration[4.2]
  def self.up
  	add_column :shows, :endate, :date
  end

  def self.down
  	remove_column :shows, :endate
  end
end
