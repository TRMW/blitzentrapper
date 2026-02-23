# frozen_string_literal: true

class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    return unless table_exists?(:active_storage_blobs)

    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string
    end

    return unless column_exists?(:active_storage_blobs, :service_name)

    # Backfill and set NOT NULL (handles partial runs where column was added but transaction aborted)
    configured_service = Rails.application.config.active_storage.service.to_s
    execute <<-SQL.squish
      UPDATE active_storage_blobs SET service_name = #{connection.quote(configured_service)} WHERE service_name IS NULL
    SQL

    change_column_null :active_storage_blobs, :service_name, false
  end

  def down
    return unless table_exists?(:active_storage_blobs)

    remove_column :active_storage_blobs, :service_name if column_exists?(:active_storage_blobs, :service_name)
  end
end
