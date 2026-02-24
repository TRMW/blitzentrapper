class AddForeignKeyToActiveStorageAttachments < ActiveRecord::Migration[6.1]
  def up
    unless foreign_key_exists?(:active_storage_attachments, :active_storage_blobs)
      add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    end
  end

  def down
    if foreign_key_exists?(:active_storage_attachments, :active_storage_blobs)
      remove_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    end
  end
end
