class Song < ActiveRecord::Base
  has_many :tracklistings
  has_many :records, through: :tracklistings

  before_validation { self.title = title.squish if title }

  # The existing song whose title matches, ignoring case and extra spaces,
  # so typing "furr " in a setlist or tracklist reuses "Furr" instead of
  # creating a duplicate. The oldest match wins if duplicates already exist.
  def self.matching_title(title)
    title = title.to_s.squish
    return if title.empty?

    where("LOWER(REGEXP_REPLACE(BTRIM(title), '\\s+', ' ', 'g')) = ?", title.downcase).order(:id).first
  end
end
