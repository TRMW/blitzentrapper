class FixTracklistings < ActiveRecord::Migration
  def self.up
  	rename_column :setlistings, :records_id, :show_id
  	rename_column :setlistings, :songs_id, :song_id
  end

  def self.down
  	rename_column :setlistings, :show_id, :records_id
  	rename_column :setlistings, :song_id, :songs_id
  end
end
