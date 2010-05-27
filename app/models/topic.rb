class Topic < ActiveRecord::Base
  has_many :posts, :dependent => :destroy
  accepts_nested_attributes_for :posts, :allow_destroy => true
  
  before_create :set_permalink
  
  def to_param
    title.parameterize
  end
end
