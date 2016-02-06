class BlogController < ApplicationController
  rescue_from Net::HTTPBadResponse, with: :redirect_to_store
  rescue_from SocketError, with: :redirect_to_store
  rescue_from Errno::ETIMEDOUT, with: :redirect_to_store
  rescue_from TypeError, with: :render_404

  def show
    @post = Rails.cache.read('tumblr_cache').to_a.find { |post| post['id'] == params[:id] } ||
      HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
        :query => {
          :api_key => ENV['TUMBLR_API_KEY'],
          :id => params[:id] })['response']['posts'][0]
  end

  def page
    @page = params[:page].to_i
    start = @page * 10
    page_data = Rails.cache.fetch("page_cache_#{@page}") do
      HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
        :query => {
          :api_key => ENV['TUMBLR_API_KEY'],
          :limit => '10',
          :offset => start })['response']
    end
    @blogposts = page_data['posts']
    @lastpage = true if page_data['blog']['posts'] < start + 11
    render :index
  end
end
