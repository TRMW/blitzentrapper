class AddMetaToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :location, :string
    add_column :users, :occupation, :string
    add_column :users, :interests, :string
  end

  def self.down
    remove_column :users, :interests
    remove_column :users, :occupation
    remove_column :users, :location
  end
end
