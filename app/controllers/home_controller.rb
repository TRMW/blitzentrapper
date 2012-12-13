class HomeController < ApplicationController
  def index
    #redirect_to :action => 'massacre', :status => 307 #307 = Temporary Redirect

    @latest_release = Record.find(:last, :order => "release_date ASC")
    @topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
    @postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
    @shows = Show.today_forward.limit(3)

    # serve cached posts unless cache is older than ten minutes
    cache_time = Rails.cache.read('tumblr_cache_saved_at')
    logger.info("tumblr_cache_saved_at = #{cache_time}")
    if cache_time.nil? || (cache_time.to_time < 10.minutes.ago)
      tumblr = HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
        :query => {
          :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
          :limit => '10'})
      # raise Net::HTTPBadResponse if response['tumblr'].nil? || response['tumblr']['posts'].nil?
      @blogposts = tumblr['response']['posts']
      Rails.cache.write('tumblr_cache', @blogposts)
      Rails.cache.write('tumblr_cache_saved_at', Time.zone.now)
    else
      get_cached_posts_or_fallback
    end

    tumblr = HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
      :query => {
        :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
        :limit => '10' })
    @blogposts = tumblr['response']['posts']
    Rails.cache.write('tumblr_cache', @blogposts)
    Rails.cache.write('tumblr_cache_saved_at', Time.zone.now)

    # serve cached posts if Tumblr is failing
    rescue Net::HTTPBadResponse
      get_cached_posts_or_fallback

    rescue SocketError
      get_cached_posts_or_fallback
  end

  def stream_auth
    if request.post?
      if /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i.match(params[:email])
        flash[:notice] = "Authorization successful!"
        redirect_to '/vh3yT4zx?key=aZ6jklasX89aUc45'
      else
        flash[:error] = "Authorization failed!"
      end
    end
  end

  def vh3yT4zx
    if flash.blank?
      flash[:error] = "Authorization failed!"
      redirect_to :home
    end
  end

  def get_cached_posts_or_fallback
    # check that cache isn't empty
    if !Rails.cache.read('tumblr_cache').blank?
      @blogposts = Rails.cache.read('tumblr_cache')
      logger.info("Used cached Tumblr posts.")
    # cache is empty so display records instead
    else
      logger.error("ERROR: Can't read cache, displaying store instead")
      logger.info(Rails.cache.read('tumblr_cache'))
      @records = Record.all(:order => 'release_date DESC')
      flash[:error] = "Sorry, that page is broken right now. Check out the shop instead?"
      redirect_to store_category_path('new')
    end
  end

  def presale
    redirect_to '/american-goldwing-promo'
  end

  #redirect to index
  def redirect
    redirect_to :action => 'index', :status => :moved_permanently
  end
end
