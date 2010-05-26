class CreateSetlistings < ActiveRecord::Migration
  def self.up
    create_table :setlistings do |t|
      t.timestamps
      t.references :records
      t.references :songs
      t.integer :track_number
    end
    rename_table :tracklists, :tracklistings
  end

  def self.down
    drop_table :setlistings
    rename_table :tracklistings, :tracklists
  end
end
