class SplitDatetime < ActiveRecord::Migration
  def self.up
  	rename_column :shows, :datetime, :date
  end

  def self.down
  	rename_column :shows, :date, :datetime
  end
end
