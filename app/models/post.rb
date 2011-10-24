class Post < ActiveRecord::Base
	belongs_to :user
  belongs_to :postable, :polymorphic => true
  validates_presence_of :body
  scope :visible, :conditions => { :visible => true }
  after_create :update_postable_freshness
  after_destroy :reset_postable_freshness
  
  def self.set_visibility
  	for post in Post.all
  		post.visible = true
  		post.save
  	end
  end
  
  def update_postable_freshness
  	postable.last_post_date = created_at
  	postable.save
  end
  
  # Set to nil if there are no longer any posts, otherwise update
  def reset_postable_freshness
  	if postable.posts.empty?
  		logger.debug "posts is empty"
			postable.last_post_date = "nil"
  	else
  		logger.debug "posts isn't empty"
			postable.last_post_date = postable.posts.last.created_at
  	end
  	postable.save
  end
end