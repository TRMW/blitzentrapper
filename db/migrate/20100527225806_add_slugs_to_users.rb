class AddSlugsToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :slug, :string
  end

  def self.down
    remove_column :users, :slug
  end
end
