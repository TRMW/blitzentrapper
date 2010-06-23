class HomeController < ApplicationController
	def index
		# response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :filter => 'none'})
		# @blogposts = response['tumblr']['posts']
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
		@shows = Show.today_forward(3)
	end
	
  #redirect to index
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end