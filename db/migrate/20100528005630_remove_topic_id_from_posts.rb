class RemoveTopicIdFromPosts < ActiveRecord::Migration[4.2]
  def self.up
  	remove_column :posts, :topic_id
  end

  def self.down
  	add_column :posts, :topic_id
  end
end
