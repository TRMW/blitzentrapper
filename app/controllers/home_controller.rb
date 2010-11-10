class HomeController < ApplicationController
	def index
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@shows = Show.today_forward.limit(3)

		response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :filter => 'none'})
		@blogposts = response['tumblr']['posts']
		Rails.cache.write('tumblr_cache', @blogposts)
		Rails.cache.write('tumblr_cache_saved_at', Time.zone.now)
	end
	
	def get_cached_posts_or_fallback
		# check that cache isn't empty
		if !Rails.cache.read('tumblr_cache').blank?
			@blogposts = Rails.cache.read('tumblr_cache')
			logger.info("Used cached Tumblr posts.")
		# cache is empty so display records instead
		else
			logger.error("ERROR: can't read cache")
			logger.info(Rails.cache.read('tumblr_cache'))
			@records = Record.all(:order => 'release_date DESC')
			render 'records/index'
		end
	end
		
  #redirect to index
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end