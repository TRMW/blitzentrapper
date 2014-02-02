class HomeController < ApplicationController
  rescue_from Net::HTTPBadResponse, with: :redirect_to_store
  rescue_from SocketError, with: :redirect_to_store
  rescue_from Errno::ETIMEDOUT, with: :redirect_to_store

  def index
    @latest_release = Record.find(:last, :order => "release_date ASC")
    @topics = Topic.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
    @postedshows = Show.find(:all, :conditions => "last_post_date IS NOT NULL", :order => "last_post_date DESC", :limit => 3)
    @shows = Show.today_forward.limit(3)
    @blogposts = Rails.cache.fetch('tumblr_cache') do
      logger.info("****** Fetching posts from Tumblr. ******")
      HTTParty.get('http://api.tumblr.com/v2/blog/blitzentrapper.tumblr.com/posts',
            :query => {
              :api_key => 'Xx2F44h0x9f9lKcwSN9lVGbZ7y8MyRNl6HoDDOWa3zNR4PlyVP',
              :limit => '10'})['response']['posts']
    end
    redirect_to_store if @blogposts.blank?
  end

  def presale
    redirect_to '/american-goldwing-promo'
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
end
