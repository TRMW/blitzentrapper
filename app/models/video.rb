class Video < ActiveRecord::Base
  belongs_to :user
  has_attached_file :clip, :path => "videos/:id/:style.:extension"
end
