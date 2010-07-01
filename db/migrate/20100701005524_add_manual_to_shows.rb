class AddManualToShows < ActiveRecord::Migration
  def self.up
    add_column :shows, :manual, :boolean
  end

  def self.down
    remove_column :shows, :manual
  end
end
