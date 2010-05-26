class AddUserAndTopicToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :user_id, :integer
    add_column :posts, :topic_id, :integer
  end

  def self.down
    remove_column :posts, :topic_id
    remove_column :posts, :user_id
  end
end
