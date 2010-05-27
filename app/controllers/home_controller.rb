class HomeController < ApplicationController
	def index
		response = HTTParty.get('http://www.trmw.org/api/read', :query => {:num => '3'})
		@posts = response['tumblr']['posts']
		@latest_release = Record.find(:last, :order => "release_date ASC")
		@topics = Topic.find(:all, :order => "updated_at DESC", :limit => 3)
	end
	
  #redirect to index
  def redirect
  	render_file '/public/index.html', :status => :moved_temporarily # remove once site is unveiled
    # redirect_to :action => 'index', :status => :moved_permanently
  end
end