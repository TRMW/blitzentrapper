class AddIndexes < ActiveRecord::Migration[4.2]
  def self.up
  	add_index :posts, :user_id
  	add_index :posts, :postable_id
  	add_index :posts, :postable_type
  	add_index :setlistings, :show_id
  	add_index :setlistings, :song_id
  	add_index :tracklistings, :records_id
  	add_index :tracklistings, :songs_id
  	add_index :shows, :visible
  end

  def self.down
  	remove_index :posts, :user_id
  	remove_index :posts, :postable_id
  	remove_index :posts, :postable_type
  	remove_index :setlistings, :show_id
  	remove_index :setlistings, :song_id
  	remove_index :tracklistings, :records_id
  	remove_index :tracklistings, :songs_id
  	remove_index :shows, :visible
  end
end
