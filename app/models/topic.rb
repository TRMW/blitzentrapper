class Topic < ActiveRecord::Base
  has_many :posts, :as => :postable, :order => "created_at ASC", :dependent => :destroy
  has_many :users, :through => :posts
  validates_presence_of :title
  accepts_nested_attributes_for :posts, :allow_destroy => true
  before_create :set_permalink

  def set_permalink
    self.slug = generate_unique_slug(title.parameterize, false)
  end

  def to_param
    slug
  end

  def generate_unique_slug(slug, number)
  	if number
  		generated_slug = "#{slug}-#{number}"
  	else
  		generated_slug = slug
  		number = 1
  	end

  	# recursively check for slug uniqueness
  	if Topic.find_by_slug(generated_slug)
  		generate_unique_slug(generated_slug, number)
  	else
  		generated_slug
  	end
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
