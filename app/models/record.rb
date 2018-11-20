class Record < ActiveRecord::Base
  has_many :tracklistings, -> { order 'track_number' }
  has_many :songs, -> { order 'tracklistings.track_number' }, :through => :tracklistings
  accepts_nested_attributes_for :tracklistings,
    :allow_destroy => true,
    :reject_if => proc { |attributes| attributes['song_id'].blank? && attributes['song_attributes']['title'].blank? }
  before_create :set_permalink
  has_one_attached :cover

  def set_permalink
    self.slug = title.parameterize
  end

  def to_param
    slug
  end
end
