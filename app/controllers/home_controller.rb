class HomeController < ApplicationController
	def index
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@shows = Show.today_forward.limit(3)
		
		# get cached post unless cache is older than ten minutes old
		cache_time = Rails.cache.read('tumblr_cache_saved_at')
		if cache_time.nil? || cache_time < 10.minutes.ago
			response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :filter => 'none'})
			@blogposts = response['tumblr']['posts']
			Rails.cache.write('tumblr_cache', @blogposts)
			Rails.cache.write('tumblr_cache_saved_at', Time.zone.now)
		else
			@blogposts = Rails.cache.read('tumblr_cache')
			logger.info("Used cached Tumblr posts.  SWEET!")
		end
		
		rescue Net::HTTPBadResponse
			logger.error("ERROR: Got Net::HTTPBadResponse when trying to access Tumblr API")
			@blogposts = Rails.cache.read('tumblr_cache')
		else
	end
	
  #redirect to index
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end