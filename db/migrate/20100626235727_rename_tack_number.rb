class RenameTackNumber < ActiveRecord::Migration
  def self.up
  	rename_column :setlistings, :track_number, :position
  end

  def self.down
  	rename_column :setlistings, :position, :track_number
  end
end
