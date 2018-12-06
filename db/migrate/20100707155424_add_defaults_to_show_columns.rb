class AddDefaultsToShowColumns < ActiveRecord::Migration[4.2]
  def self.up
  	change_column_default :shows, :manual, false
  	change_column_default :shows, :festival_dupe, false
  end

  def self.down
  	change_column_default :shows, :manual, nil
  	change_column_default :shows, :festival_dupe, nil
  end
end
