class ChangeLatLongColumnsToFloat < ActiveRecord::Migration[4.2]
  def self.up
  	change_column :shows, :latitude, :float
  	change_column :shows, :longitude, :float
  end

  def self.down
  	change_column :shows, :latitude, :integer
  	change_column :shows, :longitude, :integer
  end
end
