class CreateSongs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :songs do |t|
      t.string :title
      t.text :player
      t.text :lyrics
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
