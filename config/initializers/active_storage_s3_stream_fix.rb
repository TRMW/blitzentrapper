# frozen_string_literal: true

# Avoid Aws::S3::Errors::BadRequest when streaming from S3. The default
# S3Service#stream calls object.exists? which uses a waiter/HeadObject; some
# bucket/region/endpoint configs return 400 for HeadObject. This patch streams
# using range GETs only (no exists?/HeadObject), getting total size from the
# first range response's Content-Range header.
#
# Must run after Active Storage is loadable; force load S3Service so prepend
# runs before any request uses it.
Rails.application.config.to_prepare do
  require "active_storage/service/s3_service"
  ActiveStorage::Service::S3Service.prepend(Module.new do
    private

    def stream(key)
      object = object_for(key)
      chunk_size = 5.megabytes
      offset = 0

      # Use a minimal range request to detect presence and get total size
      # instead of object.exists? (HeadObject), which can return 400 for
      # some bucket/region/endpoint configurations.
      first = object.get(range: "bytes=0-0")
      content_range = first.content_range
      total = if content_range
        content_range.split("/").last.to_i
      else
        # Some S3-compatible endpoints omit Content-Range; use body size as fallback
        first.body.size.positive? ? 1 : 0
      end
      raise ActiveStorage::FileNotFoundError if total.zero?

      # Yield the first byte we already fetched (for 1-byte file we're done)
      yield first.body.string.force_encoding(Encoding::BINARY)
      offset = 1

      while offset < total
        range_end = [offset + chunk_size - 1, total - 1].min
        chunk = object.get(range: "bytes=#{offset}-#{range_end}").body.string
        yield chunk.force_encoding(Encoding::BINARY)
        offset += chunk_size
      end
    rescue Aws::S3::Errors::NoSuchKey
      raise ActiveStorage::FileNotFoundError
    end
  end)
end
