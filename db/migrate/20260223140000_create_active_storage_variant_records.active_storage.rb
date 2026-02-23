# frozen_string_literal: true

class CreateActiveStorageVariantRecords < ActiveRecord::Migration[8.0]
  def change
    return if table_exists?(:active_storage_variant_records)

    create_table :active_storage_variant_records do |t|
      t.belongs_to :blob, null: false, index: false
      t.string :variation_digest, null: false

      t.index [:blob_id, :variation_digest], name: "index_active_storage_variant_records_uniqueness", unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
  end
end
