class AddVisibleToPosts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :posts, :visible, :boolean, :default => true
    add_index :posts, :visible
  end

  def self.down
    remove_column :posts, :visible
    remove_index :posts, :visible
  end
end
