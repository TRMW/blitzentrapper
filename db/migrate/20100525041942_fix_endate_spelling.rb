class FixEndateSpelling < ActiveRecord::Migration
  def self.up
  	rename_column :shows, :endate, :enddate
  end

  def self.down
  	rename_column :shows, :enddate, :endate
  end
end
