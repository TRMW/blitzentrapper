class AddSlugToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :slug, :string
  end

  def self.down
    remove_column :records, :slug
  end
end
