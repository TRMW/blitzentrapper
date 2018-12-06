class AddOauth2FieldsToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :oauth2_token, :string
    add_index :users, :oauth2_token
  end

  def self.down
    remove_column :users, :oauth2_token
  end
end
