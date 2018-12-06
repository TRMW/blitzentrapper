class AddCoverArtColunToRecords < ActiveRecord::Migration[4.2]
  def self.up
    add_column :records, :cover_file_name, :string
  end

  def self.down
    remove_column :records, :cover_file_name
  end
end
