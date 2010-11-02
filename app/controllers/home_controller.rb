class HomeController < ApplicationController
	def index
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@shows = Show.today_forward.limit(3)
		
		# get cached post unless cache is older than ten minutes old
		cache_time = Rails.cache.read('tumblr_cache_saved_at')
		if 1 == 1
			response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :filter => 'none'})
			raise Net::HTTPBadResponse if response['tumblr'].nil?
			@blogposts = response['tumblr']['posts']
			Rails.cache.write('tumblr_cache', @blogposts)
			Rails.cache.write('tumblr_cache_saved_at', Time.zone.now)
		else
			# if cache is less than ten minutes old or tumblr is failing, use cache
			if !Rails.cache.read('tumblr_cache').blank?
				@blogposts = Rails.cache.read('tumblr_cache')
				logger.info("Used cached Tumblr posts.")
			else
				logger.error("ERROR: response['tumblr'] us nil while trying to access Tumblr API")
				@records = Record.all(:order => 'release_date DESC')
				render 'records/index'
			end
		end
		
		# serve cached posts if Tumblr is failing
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