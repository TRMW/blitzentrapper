class AddPostableToPosts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :posts, :postable_id, :integer
    add_column :posts, :postable_type, :string
  end

  def self.down
    remove_column :posts, :postable_id
    remove_column :posts, :postable_type
  end
end
