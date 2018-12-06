class CreateRecords < ActiveRecord::Migration[4.2]
  def self.up
    create_table :records do |t|
      t.string :title
      t.date :release_date
      t.string :label
      t.text :buy_buttons
      t.text :player
      t.string :edition
      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
