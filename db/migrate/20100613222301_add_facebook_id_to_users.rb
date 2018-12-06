class AddFacebookIdToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :fbid, :string
  end

  def self.down
    remove_column :users, :fbid
  end
end
