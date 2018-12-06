class AddStickyToTopics < ActiveRecord::Migration[4.2]
  def self.up
  	add_column :topics, :sticky, :boolean
  end

  def self.down
  	remove_column :topics, :sticky
  end
end
