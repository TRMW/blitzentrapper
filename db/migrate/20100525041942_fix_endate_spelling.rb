class FixEndateSpelling < ActiveRecord::Migration[4.2]
  def self.up
  	rename_column :shows, :endate, :enddate
  end

  def self.down
  	rename_column :shows, :enddate, :endate
  end
end
