class Post < ActiveRecord::Base
	belongs_to :user
  belongs_to :postable, :polymorphic => true
  after_create :update_topic_freshness
  after_destroy :reset_topic_freshness
  
  def update_topic_freshness
  	postable.last_post_date = created_at
  	postable.save
  end
  
  def reset_topic_freshness
  	most_recent_post = postable.posts(:order => :created_at).last
  	postable.last_post_date = most_recent_post.created_at
  	postable.save
  end
end