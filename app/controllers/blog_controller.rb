class BlogController < ApplicationController
	def index
		response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10'})
		@posts = response['tumblr']['posts']
  	# @page = 1
	end
	
	def show
		@post = Rails.cache.read('tumblr_cache')['post'].find { |post| post['id'] == params[:id] } || HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:id => params[:id]})['tumblr']['posts']['post']
	end
	
	def page
		@page = params[:id].to_i
		@nextpage = @page + 1
		start = @page * 10
		response = HTTParty.get('http://blitzentrapper.tumblr.com/api/read', :query => {:num => '10', :start => start})
		@posts = response['tumblr']['posts']
		render :index
	end
end
