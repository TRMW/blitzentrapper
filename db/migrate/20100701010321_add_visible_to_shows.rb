class AddVisibleToShows < ActiveRecord::Migration[4.2]
  def self.up
    add_column :shows, :visible, :boolean, :default => true
  end

  def self.down
    remove_column :shows, :visible
  end
end
