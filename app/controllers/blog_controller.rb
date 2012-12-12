class BlogController < ApplicationController
  def index
    redirect_to :root
  end

  def show
    # serve cached post if it's available, otherwise hit Tumblr API
    @post = Rails.cache.read('tumblr_cache').find { |post| post['id'] == params[:id] } ||
            HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
              :query => {
                :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
                :id => params[:id] })['response']['posts'][0]

    # redirect to records if Tumblr is down
    rescue SocketError
      render 'store/new'
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

    # redirect to records if Tumblr is down
    rescue SocketError
      render 'store/new'
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
        post['title'] = youtube_info['entry']['title']['$t']
        post['thumbnail'] = youtube_info['entry']['media$group']['media$thumbnail'][1]['url']

      elsif embed.match('vimeo')
        video_id = embed.match(/video\/(\d*)/)[1]
        vimeo_info = HTTParty.get("http://vimeo.com/api/v2/video/#{video_id}.json")
        post['title'] = vimeo_info[0]['title']
        post['thumbnail'] = vimeo_info[0]['thumbnail_large']
      end

      @videos << post
    end

    # redirect to records if Tumblr is down
    rescue SocketError
      render 'store/new'
  end
end
