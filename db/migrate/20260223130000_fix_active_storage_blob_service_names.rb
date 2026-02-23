# frozen_string_literal: true

# Ensures all Active Storage blobs have service_name set to the currently
# configured service (e.g. "amazon" in production). Fixes 500s when blobs
# were backfilled with the wrong service (e.g. "local") during migration.
class FixActiveStorageBlobServiceNames < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    return unless table_exists?(:active_storage_blobs)
    return unless column_exists?(:active_storage_blobs, :service_name)

    configured = Rails.application.config.active_storage.service.to_s
    quoted = connection.quote(configured)
    execute <<-SQL.squish
      UPDATE active_storage_blobs
      SET service_name = #{quoted}
      WHERE service_name IS NULL OR service_name != #{quoted}
    SQL
  end

  def down
    # No-op: cannot safely revert to wrong values
  end
end
