class BlogController < ApplicationController
  rescue_from Net::HTTPBadResponse, with: :redirect_to_store
  rescue_from SocketError, with: :redirect_to_store
  rescue_from Errno::ETIMEDOUT, with: :redirect_to_store

  def show
    @post = Rails.cache.read('tumblr_cache').to_a.find { |post| post['id'] == params[:id] } ||
            HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
              :query => {
                :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
                :id => params[:id] })['response']['posts'][0]
  end

  def page
    @page = params[:page].to_i
    start = @page * 10
    page_data = Rails.cache.fetch("page_cache_#{@page}") do
      HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
        :query => {
          :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
          :limit => '10',
          :offset => start })['response']
    end
    @blogposts = page_data['posts']
    @lastpage = true if page_data['blog']['posts'] < start + 11
    render :index
  end

  def videos
    @videos = []
    blogposts = Rails.cache.fetch('video_cache') do
        logger.info("****** Fetching video posts from Tumblr. ******")
        HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
          :query => {
            :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
            :type => 'video',
            :tag => 'video' })['response']['posts']
    end

    blogposts.each do |post|
      embed = post['player'][1]['embed_code']

      if embed.match('youtube')
        video_id = embed.match(/embed\/(.*)\?/)[1]
        youtube_info = Rails.cache.fetch("youtube_cache_#{video_id}", expires_in: 1.week) do
          logger.info("****** Fetching video metadata from YouTube. ******")
          HTTParty.get("https://gdata.youtube.com/feeds/api/videos/#{video_id}?v=2&alt=json")['entry']
        end
        next unless youtube_info
        post['title'] = youtube_info['title']['$t']
        @videos << post

      elsif embed.match('vimeo')
        video_id = embed.match(/video\/(\d*)/)[1]
        vimeo_info = Rails.cache.fetch("vimeo_cache_#{video_id}", expires_in: 1.week) do
          logger.info("****** Fetching video metadata from Vimeo. ******")
          HTTParty.get("http://vimeo.com/api/v2/video/#{video_id}.json")[0]
        end
        next unless vimeo_info
        post['title'] = vimeo_info['title']
        @videos << post

      else
        @videos << post
      end
    end
    @videos
  end
end
