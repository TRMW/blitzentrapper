class CreateTracklists < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tracklists do |t|
      t.references :records
      t.references :songs
      t.integer :track_number
      t.timestamps
      drop_table :records_songs
    end
  end

  def self.down
    drop_table :tracklists
  end
end
