class ShowsRenameAgestColumn < ActiveRecord::Migration
  def self.up
  rename_column :shows, :agest, :ages
  remove_column :shows, :time
  add_column :shows, :bit_id, :integer
  add_column :shows, :status, :string
  add_column :shows, :country, :string
  add_column :shows, :latitude, :integer
  add_column :shows, :longitude, :integer
  end

  def self.down
  rename_column :shows, :ages, :agest
  add_column :shows, :time
  remove_column :shows, :bit_id
  remove_column :shows, :status
  remove_column :shows, :country
  remove_column :shows, :latitude
  remove_column :shows, :longitude
  end
end
