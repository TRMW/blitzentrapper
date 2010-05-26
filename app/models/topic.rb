class Topic < ActiveRecord::Base
  attr_accessible :id, :title, :slug, :posts_attributes
  has_many :posts, :dependent => :destroy
  accepts_nested_attributes_for :posts, :allow_destroy => true
end
