class Topic < ActiveRecord::Base
  has_many :posts, :dependent => :destroy
  accepts_nested_attributes_for :posts, :allow_destroy => true
  
  before_create :set_permalink
  
  def set_permalink
    self.slug = title.parameterize
  end
  
  def to_param
    slug
  end
end
