class BlogController < ApplicationController
  rescue_from Net::HTTPBadResponse, with: :redirect_to_store
  rescue_from SocketError, with: :redirect_to_store
  rescue_from Errno::ETIMEDOUT, with: :redirect_to_store

  def show
    @post = Rails.cache.read('tumblr_cache').find { |post| post['id'] == params[:id] } ||
            HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
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

  def videos
    tumblr = HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
      :query => {
        :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
        :type => 'video',
        :tag => 'video' })
    @videos = []

    tumblr['response']['posts'].each do |post|
      embed = post['player'][1]['embed_code']

      if embed.match('youtube')
        video_id = embed.match(/embed\/(.*)\?/)[1]
        youtube_info = HTTParty.get("https://gdata.youtube.com/feeds/api/videos/#{video_id}?v=2&alt=json")
        next unless youtube_info['entry']
        post['title'] = youtube_info['entry']['title']['$t']
        post['thumbnail'] = youtube_info['entry']['media$group']['media$thumbnail'][1]['url']

      elsif embed.match('vimeo')
        next
      #   video_id = embed.match(/video\/(\d*)/)[1]
      #   vimeo_info = HTTParty.get("http://vimeo.com/api/v2/video/#{video_id}.json")
      #   next unless vimeo_info[0]
      #   post['title'] = vimeo_info[0]['title']
      #   post['thumbnail'] = vimeo_info[0]['thumbnail_large']
      end

      @videos << post
    end
  end
end
