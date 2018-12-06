class AddAvatarColumnsToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :avatar_file_name, :string
  end

  def self.down
    remove_column :users, :avatar_file_name
  end
end
