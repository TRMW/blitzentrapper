class AddCoverArtColunToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :cover_file_name, :string
  end

  def self.down
    remove_column :records, :cover_file_name
  end
end
