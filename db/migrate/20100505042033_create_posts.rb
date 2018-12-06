class CreatePosts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :posts do |t|
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
