class CreateProducts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :products do |t|
      t.string :name
      t.text :description
      t.text :buy_buttons
      t.string :image_file_name
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
