class AddUserIdToVideos < ActiveRecord::Migration[4.2]
  def self.up
  	add_column :videos, :user_id, :integer
  	remove_column :videos, :name
  end

  def self.down
  	remove_column :videos, :user_id
  	add_column :videos, :name, :string
  end
end
