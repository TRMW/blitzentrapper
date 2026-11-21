class Setlisting < ActiveRecord::Base
  belongs_to :show
  belongs_to :song, optional: true
  acts_as_list scope: :show
  accepts_nested_attributes_for :song, allow_destroy: true, reject_if: proc { |attributes| attributes["title"].blank? }

  # Serializes unsaved (in-memory) records with a stable temporary id. Blank
  # setlistings built by Show#setlistings_with_blanks need a unique id to use
  # as a React draggable id; otherwise they would all have id: null.
  #
  # This is done only in the JSON and not by overriding #id, because
  # acts_as_list and ActiveRecord use #id when saving new records, and a
  # "temp_..." id there makes Postgres reject the query.
  def serializable_hash(options = nil)
    hash = super
    hash["id"] ||= "temp_#{object_id}" if hash.key?("id")
    hash
  end
end
