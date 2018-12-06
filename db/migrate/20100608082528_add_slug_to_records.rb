class AddSlugToRecords < ActiveRecord::Migration[4.2]
  def self.up
    add_column :records, :slug, :string
  end

  def self.down
    remove_column :records, :slug
  end
end
