class AddEncoreToShows < ActiveRecord::Migration[4.2]
  def self.up
    add_column :shows, :encore, :integer, :default => '20'
  end

  def self.down
    remove_column :shows, :encore
  end
end
