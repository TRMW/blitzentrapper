class Video < ActiveRecord::Base
	belongs_to :user
  has_attached_file :clip, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :s3_host_alias => "files.blitzentrapper.net", :url => ":s3_alias_url", :path => "videos/:id/:style.:extension"
end
