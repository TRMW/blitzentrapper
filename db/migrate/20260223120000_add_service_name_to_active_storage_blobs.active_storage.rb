# frozen_string_literal: true

class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:active_storage_blobs)

    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string

      configured_service = ActiveStorage::Blob.service.name
      ActiveStorage::Blob.unscoped.update_all(service_name: configured_service)

      change_column_null :active_storage_blobs, :service_name, false
    end
  end

  def down
    return unless table_exists?(:active_storage_blobs)

    remove_column :active_storage_blobs, :service_name if column_exists?(:active_storage_blobs, :service_name)
  end
end
