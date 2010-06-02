class Post < ActiveRecord::Base
	belongs_to :user
  belongs_to :postable, :polymorphic => true
  after_create :update_topic
  
  def update_topic
  	postable.last_post_date = created_at
  	postable.save
  end
end
