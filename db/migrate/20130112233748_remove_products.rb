class RemoveProducts < ActiveRecord::Migration[4.2]
  def up
    drop_table :products
  end

  def down
    create_table :products do |t|
      t.string :name
      t.text :description
      t.text :buy_buttons
      t.string :image_file_name
      t.timestamps
    end
  end
end
