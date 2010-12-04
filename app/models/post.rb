class Post < ActiveRecord::Base
	belongs_to :user
  belongs_to :postable, :polymorphic => true
  validates_presence_of :body
  # named_scope :visible, :conditions => { :visible => true }
  after_create :update_topic_freshness
  after_destroy :reset_topic_freshness
  
  def update_topic_freshness
  	postable.last_post_date = created_at
  	postable.save
  end
  
  def reset_topic_freshness
  	most_recent_post = postable.posts(:order => :created_at).last
  	if most_recent_post.nil?
  		logger.debug "most recent post is nil"
  		postable.last_post_date = "NULL"
  		postable.save
  		logger.debug "set postable.last_post_date to #{postable.last_post_date}"
  	else
  		logger.debug "most recent post is #{most_recent_post}"
  		postable.last_post_date = most_recent_post.created_at
  		postable.save
  	end
  end
end