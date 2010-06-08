class HomeController < ApplicationController
	def index
		response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '3'})
		@blogposts = response['tumblr']['posts']
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@posts = Post.find(:all, :order => "created_at DESC", :limit => 3)
		@shows = Show.today_forward(3)
	end
	
  #redirect to index
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end