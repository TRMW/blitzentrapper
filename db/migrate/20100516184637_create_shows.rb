class CreateShows < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shows do |t|
      t.string :city
      t.date :date
      t.time :time
      t.string :agest
      t.string :venue
      t.string :support1
      t.string :support2
      t.string :support3
      t.string :ticket_link
      t.text :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :shows
  end
end
