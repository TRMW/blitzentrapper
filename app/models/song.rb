class Song < ActiveRecord::Base
  has_many :tracklistings
  has_many :records, :through => :tracklistings
end
