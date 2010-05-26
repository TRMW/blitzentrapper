class AddTimeToShows < ActiveRecord::Migration
  def self.up
  	add_column :shows, :time, :time
  	change_column :shows, :date, :date
  end

  def self.down
    remove_column :shows, :time, :time
  	change_column :shows, :date, :datetime
  end
end
