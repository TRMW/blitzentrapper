class CreateRecordSongJoinTable < ActiveRecord::Migration[4.2]
  def self.up
  	create_table :records_songs, :id => false do |t|
      t.integer :record_id
      t.integer :song_id
    end
  end

  def self.down
  	drop_table :records_songs
  end
end
