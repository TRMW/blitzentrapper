class Record < ActiveRecord::Base
  has_many :tracklistings, :order => :track_number
  has_many :songs, :through => :tracklistings, :order => 'tracklistings.track_number'
  accepts_nested_attributes_for :tracklistings,
    :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['song_id'].blank? && attributes['song_attributes']['title'].blank? }
  before_create :set_permalink
  has_attached_file :cover,
                    :styles => { :big => "400x400", :medium => "240x240#", :tiny => "30x30" },
                    :path => "covers/:slug/:style.:extension"
  validates_attachment_file_name :cover, :matches => [/png\Z/i, /jpe?g\Z/i, /gif\Z/i]

  def set_permalink
    self.slug = title.parameterize
  end

  def to_param
    slug
  end
end
