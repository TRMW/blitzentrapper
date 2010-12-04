class AddVisibleToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :visible, :boolean, :default => false
    add_index :posts, :visible
  end

  def self.down
    remove_column :posts, :visible
    remove_index :posts, :visible
  end
end
