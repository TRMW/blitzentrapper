class HomeController < ApplicationController
	def index
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@shows = Show.today_forward.limit(3)
		
		# serve cached posts unless cache is older than ten minutes
		cache_time = Rails.cache.read('tumblr_cache_saved_at')
		logger.info("tumblr_cache_saved_at = #{cache_time}")
		if cache_time.to_time < 10.minutes.ago
			response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :filter => 'none'})
			raise Net::HTTPBadResponse if response['tumblr'].nil?
			@blogposts = response['tumblr']['posts']
			Rails.cache.write('tumblr_cache', @blogposts)
			Rails.cache.write('tumblr_cache_saved_at', Time.zone.now)
		else
			get_cached_posts_or_fallback
		end
		
		# serve cached posts if Tumblr is failing
		rescue Net::HTTPBadResponse
			get_cached_posts_or_fallback
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