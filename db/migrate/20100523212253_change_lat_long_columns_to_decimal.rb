class ChangeLatLongColumnsToDecimal < ActiveRecord::Migration
  def self.up
  	change_column :shows, :latitude, :decimal
  	change_column :shows, :longitude, :decimal
  end

  def self.down
  	change_column :shows, :latitude, :float
  	change_column :shows, :longitude, :float
  end
end
