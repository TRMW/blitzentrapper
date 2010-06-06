class Topic < ActiveRecord::Base
  has_many :posts, :as => :postable, :order => "created_at ASC", :dependent => :destroy
  has_many :users, :through => :posts
  validates_presence_of :title
  accepts_nested_attributes_for :posts, :allow_destroy => true
  before_create :set_permalink
  cattr_reader :per_page
    @@per_page = 20
  
  def set_permalink
    self.slug = title.parameterize
  end
  
  def to_param
    slug
  end
  
  def self.set_last_post_date
  	topics = Topic.all
  	for topic in topics do
  		most_recent_post = topic.posts(:order => :created_at).last
  		topic.last_post_date = most_recent_post.created_at
  		topic.save
  	end
  end
end
