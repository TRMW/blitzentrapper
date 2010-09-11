class HomeController < ApplicationController
	def index
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@shows = Show.today_forward.limit(3)
		response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :filter => 'none'})
		if response['tumblr'].nil?
			@records = Record.all(:order => 'release_date DESC')
			render 'records/index'
		else
			@blogposts = response['tumblr']['posts']
		end
		
		rescue Net::HTTPBadResponse
			logger.debug("Got error Net::HTTPBadResponse when trying to access Tumblr API")
			@records = Record.all(:order => 'release_date DESC')
			render 'records/index' and return
		else
	end
	
  #redirect to index
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end