class Post < ActiveRecord::Base
	belongs_to :user
  belongs_to :postable, :polymorphic => true
  validates_presence_of :body
  scope :visible, :conditions => { :visible => true }
  after_create :update_topic_freshness
  after_destroy :reset_topic
  
  def update_topic_freshness
  	postable.last_post_date = created_at
  	postable.save
  end
  
  def self.set_visibility
  	for post in Post.all
  		post.visible = true
  		post.save
  	end
  end
  
  def reset_topic
  	# Delete Topic (but not Show) if we're deleting the last post
  	if postable.posts.empty?
  		if postable_type == 'Topic'
  			postable.destroy
  		end
  	# Otherwise update Topic/Show freshness
  	else
  		postable.last_post_date = most_recent_post.created_at
  		postable.save
  	end
  end
end