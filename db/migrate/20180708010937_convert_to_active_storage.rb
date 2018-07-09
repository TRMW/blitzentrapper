Dir[Rails.root.join("app/models/**/*.rb")].sort.each { |file| require file }

class ConvertToActiveStorage < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def up
    # postgres
    get_blob_id = 'LASTVAL()'
    # mariadb
    # get_blob_id = 'LAST_INSERT_ID()'
    # sqlite
    # get_blob_id = 'LAST_INSERT_ROWID()'

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, $4, $5)
    SQL

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
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
            unless instance.send("#{attachment}_file_name").nil?
              ActiveRecord::Base.connection.raw_connection.exec_prepared("active_storage_blob_statement", [
                key(instance, attachment),
                instance.send("#{attachment}_file_name"),
                filesize(instance.send(attachment)),
                checksum(instance.send(attachment)),
                instance.updated_at.iso8601
              ])

              ActiveRecord::Base.connection.raw_connection.
                exec_prepared("active_storage_attachment_statement", [
                  attachment, model.name, instance.id, instance.updated_at.iso8601
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

  private

  def key(instance, attachment)
    SecureRandom.uuid
    # Alternatively:
    # instance.send("#{attachment}_file_name")
  end

  def checksum(attachment)
    # local files stored on disk:
    # url = attachment.path
    # Digest::MD5.base64digest(File.read(url))

    # remote files stored on another person's computer:
    url = 'http:' + attachment.url
    Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
  end

  def filesize(attachment)
    url = 'http:' + attachment.url
    response = Net::HTTP.get_response(URI(url))
    response['content-length']
  end
end
