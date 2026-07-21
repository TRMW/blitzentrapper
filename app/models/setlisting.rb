class Setlisting < ActiveRecord::Base
  belongs_to :show
  belongs_to :song, optional: true
  acts_as_list :scope => :show
  accepts_nested_attributes_for :song, :allow_destroy => true, :reject_if => proc { |attributes| attributes['title'].blank? }

  # Returns the database ID for persisted records, or a consistent temporary
  # ID for unsaved (in-memory) records. This ensures blank setlistings built
  # by Show#setlistings_with_blanks always have a unique, stable identifier
  # to use as a React draggableId, avoiding duplicate key errors when
  # multiple blank rows would otherwise all have id: null.
  def id
    persisted_id = super

    return persisted_id unless persisted_id.nil?

    @temp_id ||= "temp_#{object_id}"
  end
end
