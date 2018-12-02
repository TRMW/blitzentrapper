require 'csv'

class Post < ActiveRecord::Base
  belongs_to :user, autosave: true
  belongs_to :postable, :polymorphic => true, autosave: true, optional:true
  validates_presence_of :body
  scope :visible, -> { where(:visible => true) }
  after_create :update_postable_freshness
  after_destroy :update_postable_on_destroy

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

  def update_postable_on_destroy
    if postable.posts.empty?
      if postable.is_a? Topic
        # Delete topic if this was the only post
        postable.destroy
      else
        postable.last_post_date = nil
      end
    else
      postable.last_post_date = postable.posts.last.created_at
    end
    postable.save
  end
end
