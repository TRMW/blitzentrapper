class AddStickyToTopics < ActiveRecord::Migration
  def self.up
  	add_column :topics, :sticky, :boolean
  end

  def self.down
  	remove_column :topics, :sticky
  end
end
