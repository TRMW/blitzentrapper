class Record < ActiveRecord::Base
  has_many :tracklistings
  has_many :songs, :through => :tracklistings
  accepts_nested_attributes_for :tracklistings, 
  	:allow_destroy => true, 
  	:reject_if => proc { |attributes| attributes['song_id'].blank? && attributes['song_attributes']['title'].blank? }
  before_create :set_permalink
  has_attached_file :cover, :styles => { :big => "400x400", :medium => "240x240#", :tiny => "30x30" }, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :s3_host_alias => "files.blitzentrapper.net", :url => ":s3_alias_url", :path => "covers/:slug/:style.:extension"
  
  def set_permalink
    self.slug = title.parameterize
  end
  
  def to_param
    slug
  end
end