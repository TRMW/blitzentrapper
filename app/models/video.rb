class Video < ActiveRecord::Base
  belongs_to :user
  has_one_attached :clip
  # has_attached_file :clip, :path => "videos/:id/:style.:extension"
end
