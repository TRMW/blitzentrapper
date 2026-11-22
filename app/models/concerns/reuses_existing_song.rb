# For models that accept nested song attributes (setlistings, tracklistings):
# a new song typed in by title is linked to the existing song with that title,
# when there is one, instead of being created again.
module ReusesExistingSong
  def song_attributes=(attributes)
    id = attributes["id"] || attributes[:id]
    existing = Song.matching_title(attributes["title"] || attributes[:title]) if id.blank?

    if existing
      self.song = existing
    else
      super
    end
  end
end
