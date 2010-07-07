class AddDefaultsToShowColumns < ActiveRecord::Migration
  def self.up
  	change_column_default :shows, :manual, false
  	change_column_default :shows, :festival_dupe, false
  end

  def self.down
  	change_column_default :shows, :manual, nil
  	change_column_default :shows, :festival_dupe, nil
  end
end
