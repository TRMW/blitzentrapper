class AddAvatarColumnsToUser2 < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_file_name, :string
  end

  def self.down
    remove_column :users, :avatar_file_name
  end
end
