Paperclip::Attachment.default_options[:storage] = :s3
Paperclip::Attachment.default_options[:s3_credentials] = { :bucket => ENV['AWS_BUCKET'], :access_key_id => ENV['AWS_ACCESS_KEY_ID_2'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY_2'] }
Paperclip::Attachment.default_options[:s3_host_alias] = "files.blitzentrapper.net"
Paperclip::Attachment.default_options[:url] = ":s3_alias_url"

Paperclip.interpolates :slug do |attachment, style|
  attachment.instance.slug
end

Paperclip.interpolates :name do |attachment, style|
  attachment.instance.name
end
