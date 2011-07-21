class BlogController < ApplicationController
	def index
		redirect_to :root
	end
	
	def show
		# serve cached post if it's available, otherwise hit Tumblr API
		@post = HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts', 
							:query => {
								:api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP', 
								:id => params[:id] })['response']['posts'][0]
	end
	
	def page
		@page = params[:page].to_i
		start = @page * 10
		tumblr = HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts', 
			:query => {
				:api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP', 
				:limit => '10', 
				:offset => start })
		@posts = tumblr['response']['posts']
		@lastpage = true if tumblr['response']['blog']['posts'] < start + 11
		render :index
	end
end
