Paperclip.interpolates :slug do |attachment, style|
  attachment.instance.slug
end

Paperclip.interpolates :name do |attachment, style|
  attachment.instance.name
end