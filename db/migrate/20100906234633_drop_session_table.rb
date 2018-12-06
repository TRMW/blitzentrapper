class DropSessionTable < ActiveRecord::Migration[4.2]
  def self.up
  	drop_table :sessions
  end

  def self.down
  end
end
