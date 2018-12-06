class SplitDatetime < ActiveRecord::Migration[4.2]
  def self.up
  	rename_column :shows, :datetime, :date
  end

  def self.down
  	rename_column :shows, :date, :datetime
  end
end
