class AddLastPostDateToShows < ActiveRecord::Migration
  def self.up
    add_column :shows, :last_post_date, :date
  end

  def self.down
    remove_column :shows, :last_post_date
  end
end
