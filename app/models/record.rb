class Record < ActiveRecord::Base
  has_many :tracklistings
  has_many :songs, :through => :tracklistings
  accepts_nested_attributes_for :tracklistings, 
  	:allow_destroy => true, 
  	:reject_if => proc { |attributes| attributes['song_id'].blank? && attributes['song_attributes']['title'].blank? }
  before_create :set_permalink

  def set_permalink
    self.slug = title.parameterize
  end
  
  def to_param
    slug
  end
end