class AddManualToShows < ActiveRecord::Migration[4.2]
  def self.up
    add_column :shows, :manual, :boolean
  end

  def self.down
    remove_column :shows, :manual
  end
end
