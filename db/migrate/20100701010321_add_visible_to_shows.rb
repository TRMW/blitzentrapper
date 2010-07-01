class AddVisibleToShows < ActiveRecord::Migration
  def self.up
    add_column :shows, :visible, :boolean, :default => 1
  end

  def self.down
    remove_column :shows, :visible
  end
end
