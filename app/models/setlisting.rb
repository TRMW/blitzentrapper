class Setlisting < ActiveRecord::Base
  belongs_to :show
  belongs_to :song
  accepts_nested_attributes_for :song, :allow_destroy => true, :reject_if => proc { |attributes| attributes['title'].blank? }
end
