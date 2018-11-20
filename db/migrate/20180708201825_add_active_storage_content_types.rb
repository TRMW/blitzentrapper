Dir[Rails.root.join("app/models/**/*.rb")].sort.each { |file| require file }

class AddActiveStorageContentTypes < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def up
    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
      UPDATE active_storage_blobs SET content_type = $1 WHERE filename = $2
    SQL

    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        model.find_each.each do |instance|
          attachments.each do |attachment|
            filename = instance.send("#{attachment}_file_name")
            unless filename.nil?
              if instance.respond_to?("#{attachment}_content_type")
                content_type = instance.send("#{attachment}_content_type")
              else
                ext = File.extname(filename)
                # videos have a content type column, so we know we're an image
                # if we're here
                content_type = ext.gsub('.', 'image/')
              end
              ActiveRecord::Base.connection.raw_connection.exec_prepared("active_storage_blob_statement", [
                content_type,
                filename
              ])
            end
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
