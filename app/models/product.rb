class Product < ActiveRecord::Base
  attr_accessible :name, :description, :buy_buttons, :image_file_name, :image
  has_attached_file :image, :styles => { :medium => "240x240" }, :default_style => :medium, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :s3_host_alias => "files.blitzentrapper.net", :url => ":s3_alias_url", :path => "products/:name/:style.:extension"
end
