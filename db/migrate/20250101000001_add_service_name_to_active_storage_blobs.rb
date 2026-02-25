class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[6.1]
  def up
    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string

      # Use config directly to avoid instantiating the storage service (e.g. S3),
      # which can fail during deploy when credentials or network are unavailable.
      configured_service = Rails.application.config.active_storage.service
      service_name = (configured_service || :local).to_s
      ActiveStorage::Blob.unscoped.update_all(service_name: service_name)

      change_column :active_storage_blobs, :service_name, :string, null: false
    end
  end

  def down
    remove_column :active_storage_blobs, :service_name if column_exists?(:active_storage_blobs, :service_name)
  end
end
