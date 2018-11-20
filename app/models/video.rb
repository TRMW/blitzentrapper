class Video < ActiveRecord::Base
  belongs_to :user
  has_one_attached :clip
end
