class ConvertLastPostDateToDatetime < ActiveRecord::Migration[4.2]
  def self.up
  	change_column :shows, :last_post_date, :datetime
  end

  def self.down
  	change_column :shows, :last_post_date, :date
  end
end
